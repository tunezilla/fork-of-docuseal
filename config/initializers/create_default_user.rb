# frozen_string_literal: true
if ENV['CREATE_DEFAULT_USER'] == 'true'
  Rails.configuration.after_initialize do
    unless User.exists?
      @account = Account.new({
        name: ENV['DEFAULT_USER_COMPANY_NAME'],
        timezone: ENV['DEFAULT_USER_TIMEZONE'],
      })
      @account.timezone = Accounts.normalize_timezone(@account.timezone)
      @user = @account.users.new({
        first_name: ENV['DEFAULT_USER_FIRST_NAME'],
        last_name: ENV['DEFAULT_USER_LAST_NAME'],
        email: ENV['DEFAULT_USER_EMAIL'],
        password: ENV['DEFAULT_USER_PASSWORD'],
      })
      @user.save
      encrypted_configs = [
        { key: EncryptedConfig::APP_URL_KEY, value: ENV['DEFAULT_USER_APP_URL'] },
        { key: EncryptedConfig::ESIGN_CERTS_KEY, value: GenerateCertificate.call.transform_values(&:to_pem) }
      ]
      @account.encrypted_configs.create!(encrypted_configs)

      Docuseal.refresh_default_url_options!
    end
  end
end
