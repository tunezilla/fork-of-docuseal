# frozen_string_literal: true

class SendSubmissionCreatedWebhookRequestJob
  include Sidekiq::Job

  sidekiq_options queue: :webhooks

  USER_AGENT = Docuseal::WEBHOOK_USER_AGENT

  MAX_ATTEMPTS = 10

  def perform(params = {})
    submission = Submission.find(params['submission_id'])

    attempt = params['attempt'].to_i

    config = Accounts.load_webhook_config(submission.account)
    url = config&.value.presence

    return if url.blank?

    preferences = Accounts.load_webhook_preferences(submission.account)

    return if preferences['submission.created'].blank?

    resp = begin
      Faraday.post(url,
                   {
                     event_type: 'submission.created',
                     timestamp: Time.current,
                     data: Submissions::SerializeForApi.call(submission)
                   }.to_json,
                   **EncryptedConfig.find_or_initialize_by(account_id: config.account_id,
                                                           key: EncryptedConfig::WEBHOOK_SECRET_KEY)&.value.to_h,
                   'Content-Type' => 'application/json',
                   'User-Agent' => USER_AGENT)
    rescue Faraday::Error
      nil
    end

    if (resp.nil? || resp.status.to_i >= 400) && attempt <= MAX_ATTEMPTS &&
       (!Docuseal.multitenant? || submission.account.account_configs.exists?(key: :plan))
      SendSubmissionCreatedWebhookRequestJob.perform_in((2**attempt).minutes, {
                                                          'submission_id' => submission.id,
                                                          'attempt' => attempt + 1,
                                                          'last_status' => resp&.status.to_i
                                                        })
    end
  end
end
