# frozen_string_literal: true

class EsignSettingsController < ApplicationController
  DEFAULT_CERT_NAME = Docuseal::DEFAULT_CERT_NAME

  CertFormRecord = Struct.new(:name, :file, :password, keyword_init: true) do
    include ActiveModel::Validations

    def to_key
      []
    end
  end

  before_action :load_encrypted_config
  authorize_resource :encrypted_config, parent: false, only: %i[new create]
  authorize_resource :encrypted_config, only: %i[update destroy show]

  def show
    cert_data = @encrypted_config.value || {}

    default_pkcs = GenerateCertificate.load_pkcs(cert_data) if cert_data['cert'].present?

    custom_pkcs_list = (cert_data['custom'] || []).map do |e|
      { 'pkcs' => OpenSSL::PKCS12.new(Base64.urlsafe_decode64(e['data']), e['password'].to_s),
        'name' => e['name'],
        'status' => e['status'] }
    end

    @pkcs_list = [
      if default_pkcs
        {
          'pkcs' => default_pkcs,
          'name' => DEFAULT_CERT_NAME,
          'status' => custom_pkcs_list.any? { |e| e['status'] == 'default' } ? 'validate' : 'default'
        }
      end,
      *custom_pkcs_list
    ].compact.reverse
  end

  def new
    @cert_record = CertFormRecord.new
  end

  def create
    @cert_record = CertFormRecord.new(**cert_params)

    if (@encrypted_config.value && @encrypted_config.value['custom']&.any? { |e| e['name'] == @cert_record.name }) ||
       @cert_record.name == DEFAULT_CERT_NAME

      @cert_record.errors.add(:name, 'already exists')

      return render turbo_stream: turbo_stream.replace(:modal, template: 'esign_settings/new'),
                    status: :unprocessable_entity
    end

    save_new_cert!(@encrypted_config, @cert_record)

    redirect_to settings_esign_path, notice: 'Certificate has been successfully added!'
  rescue OpenSSL::PKCS12::PKCS12Error => e
    Rollbar.error(e) if defined?(Rollbar)

    @cert_record.errors.add(:password, e.message)

    render turbo_stream: turbo_stream.replace(:modal, template: 'esign_settings/new'), status: :unprocessable_entity
  end

  def update
    @encrypted_config.value['custom'].each { |e| e['status'] = 'validate' }

    custom_cert_data = @encrypted_config.value['custom'].find { |e| e['name'] == params[:name] }
    custom_cert_data['status'] = 'default' if custom_cert_data

    @encrypted_config.save!

    redirect_to settings_esign_path, notice: 'Default certificate has been selected'
  end

  def destroy
    @encrypted_config.value['custom'].reject! { |e| e['name'] == params[:name] }

    @encrypted_config.save!

    redirect_to settings_esign_path, notice: 'Certificate has been removed'
  end

  private

  def load_encrypted_config
    @encrypted_config = EncryptedConfig.find_or_initialize_by(account: current_account,
                                                              key: EncryptedConfig::ESIGN_CERTS_KEY)
  end

  def save_new_cert!(cert_configs, cert_record)
    pkcs = OpenSSL::PKCS12.new(cert_record.file.read, cert_record.password)

    cert_configs.value ||= {}
    cert_configs.value['custom'] ||= []
    cert_configs.value['custom'].each { |e| e['status'] = 'validate' }
    cert_configs.value['custom'] << {
      data: Base64.urlsafe_encode64(pkcs.to_der),
      password: cert_record.password,
      name: cert_record.name,
      status: 'default'
    }

    cert_configs.save!
  end

  def cert_params
    return {} if params[:esign_settings_controller_cert_form_record].blank?

    params.require(:esign_settings_controller_cert_form_record).permit(:name, :file, :password)
  end
end
