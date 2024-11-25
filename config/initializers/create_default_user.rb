# frozen_string_literal: true
if ENV['CREATE_DEFAULT_USER'] == 'true'
  Rails.configuration.after_initialize do
    unless User.exists?
      @account = Account.new({
        name: ENV['DEFAULT_ACCOUNT_COMPANY_NAME'],
        timezone: ENV['DEFAULT_ACCOUNT_TIMEZONE'],
      })
      @account.timezone = Accounts.normalize_timezone(@account.timezone)
      @user = @account.users.new({
        first_name: ENV['DEFAULT_USER_FIRST_NAME'],
        last_name: ENV['DEFAULT_USER_LAST_NAME'],
        email: ENV['DEFAULT_USER_EMAIL'],
        password: ENV['DEFAULT_USER_PASSWORD'],
      })
      @user.save

      if ENV['DEFAULT_USER_ACCESS_TOKEN']
        @user.access_token.token = ENV['DEFAULT_USER_ACCESS_TOKEN']
        @user.access_token.save!
      end

      encrypted_configs = [
        { key: EncryptedConfig::APP_URL_KEY, value: ENV['DEFAULT_ACCOUNT_APP_URL'] },
        { key: EncryptedConfig::ESIGN_CERTS_KEY, value: GenerateCertificate.call.transform_values(&:to_pem) }
      ]
      @account.encrypted_configs.create!(encrypted_configs)

      AccountConfig.find_or_initialize_by(account: @account, key: AccountConfig::ALLOW_TO_RESUBMIT).update({
        value: ENV['DEFAULT_ACCOUNT_ALLOW_TO_RESUBMIT'] == 'true',
      })

      AccountConfig.find_or_initialize_by(account: @account, key: AccountConfig::WITH_SIGNATURE_ID).update({
        value: ENV['DEFAULT_ACCOUNT_WITH_SIGNATURE_ID'] == 'true',
      })

      AccountConfig.find_or_initialize_by(account: @account, key: AccountConfig::COMBINE_PDF_RESULT_KEY).update({
        value: ENV['DEFAULT_ACCOUNT_COMBINE_PDF_RESULT'] == 'true',
      })

      if ENV['DEFAULT_ACCOUNT_WEBHOOK_URL']
        @webhook_url = @account.webhook_urls.first_or_initialize
        @webhook_url.url = ENV['DEFAULT_ACCOUNT_WEBHOOK_URL']
        @webhook_url.save!
      end

      Docuseal.refresh_default_url_options!
    end
  end
end
