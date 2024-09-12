# frozen_string_literal: true

module ApiFork
  class TemplatesUploadsController < Api::ApiBaseController
    PDF_CONTENT_TYPE = 'application/pdf'

    load_and_authorize_resource :template, parent: false

    def show; end

    def create
      url_params = create_file_params_from_url if params[:url].present?

      save_template!(@template, params)

      documents = Templates::CreateAttachments.call(@template, params, extract_fields: true)
      schema = documents.map { |doc| { attachment_uuid: doc.uuid, name: doc.filename.base } }

      if @template.fields.blank?
        @template.fields = Templates::ProcessDocument.normalize_attachment_fields(@template, documents)

        schema.each { |item| item['pending_fields'] = true } if @template.fields.present?
      end

      @template.update!(schema:)

      SendTemplateCreatedWebhookRequestJob.perform_async('template_id' => @template.id)

      render json: Templates::SerializeForApi.call(@template)
    rescue StandardError => e
      Rollbar.error(e) if defined?(Rollbar)

      raise if Rails.env.local?

      return render json: { error: 'Unable to upload file' }, status: :unprocessable_entity
    end

    private

    def save_template!(template, url_params)
      template.account = current_account
      template.author = current_user
      template.folder = TemplateFolders.find_or_create_by_name(current_user, params[:folder_name] || 'API')
      template.name = File.basename((url_params || params)[:files].first.original_filename, '.*')
      template.source = :api

      template.save!

      template
    end

    def create_file_params_from_url
      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write(DownloadUtils.call(params[:url]).body)
      tempfile.rewind

      file = ActionDispatch::Http::UploadedFile.new(
        tempfile:,
        filename: File.basename(
          URI.decode_www_form_component(params[:filename].presence || params[:url]), '.*'
        ),
        type: Marcel::MimeType.for(tempfile)
      )

      { files: [file] }
    end
  end
end
