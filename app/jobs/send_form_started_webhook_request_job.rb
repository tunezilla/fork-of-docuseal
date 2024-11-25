# frozen_string_literal: true

class SendFormStartedWebhookRequestJob
  include Sidekiq::Job

  sidekiq_options queue: :webhooks

  USER_AGENT = Docuseal::WEBHOOK_USER_AGENT

  MAX_ATTEMPTS = 10

  def perform(params = {})
    submitter = Submitter.find(params['submitter_id'])
    webhook_url = WebhookUrl.find(params['webhook_url_id'])

    attempt = params['attempt'].to_i

    return if webhook_url.url.blank? || webhook_url.events.exclude?('form.started')

    ActiveStorage::Current.url_options = Docuseal.default_url_options

    resp = begin
      Faraday.post(webhook_url.url,
                   {
                     event_type: 'form.started',
                     timestamp: Time.current,
                     data: Submitters::SerializeForWebhook.call(submitter)
                   }.to_json,
                   **webhook_url.secret.to_h,
                   'Content-Type' => 'application/json',
                   'User-Agent' => USER_AGENT)
    rescue Faraday::Error
      nil
    end

    if (resp.nil? || resp.status.to_i >= 400) && attempt <= MAX_ATTEMPTS &&
       (!Docuseal.multitenant? || submitter.account.account_configs.exists?(key: :plan))
      SendFormStartedWebhookRequestJob.perform_in((2**attempt).minutes, {
                                                    'submitter_id' => submitter.id,
                                                    'webhook_url_id' => webhook_url.id,
                                                    'attempt' => attempt + 1,
                                                    'last_status' => resp&.status.to_i
                                                  })
    end
  end
end
