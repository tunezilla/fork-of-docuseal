# frozen_string_literal: true

module EmailMessages
  module_function

  def find_or_create_for_account_user(account, user, subject, body)
    subject = I18n.t(:you_are_invited_to_sign_a_document) if subject.blank?

    sha1 = Digest::SHA1.hexdigest({ subject:, body: }.to_json)

    message = account.email_messages.find_by(sha1:)

    message ||= account.email_messages.create!(author: user, subject:, body:)

    message
  end
end
