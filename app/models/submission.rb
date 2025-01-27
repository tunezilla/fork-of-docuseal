# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id                  :bigint           not null, primary key
#  archived_at         :datetime
#  expire_at           :datetime
#  preferences         :text             not null
#  slug                :string           not null
#  source              :text             not null
#  submitters_order    :string           not null
#  template_fields     :text
#  template_schema     :text
#  template_submitters :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :bigint           not null
#  created_by_user_id  :bigint
#  template_id         :bigint           not null
#
# Indexes
#
#  index_submissions_on_account_id_and_id   (account_id,id)
#  index_submissions_on_created_by_user_id  (created_by_user_id)
#  index_submissions_on_slug                (slug) UNIQUE
#  index_submissions_on_template_id         (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_user_id => users.id)
#  fk_rails_...  (template_id => templates.id)
#
class Submission < ApplicationRecord
  belongs_to :template
  belongs_to :account
  belongs_to :created_by_user, class_name: 'User', optional: true

  has_many :submitters, dependent: :destroy
  has_many :submission_events, dependent: :destroy

  attribute :preferences, :string, default: -> { {} }

  serialize :template_fields, coder: JSON
  serialize :template_schema, coder: JSON
  serialize :template_submitters, coder: JSON
  serialize :preferences, coder: JSON

  attribute :source, :string, default: 'link'
  attribute :submitters_order, :string, default: 'random'

  attribute :slug, :string, default: -> { SecureRandom.base58(14) }

  has_one_attached :audit_trail
  has_one_attached :combined_document

  has_many_attached :preview_documents

  has_many :template_accesses, primary_key: :template_id, foreign_key: :template_id, dependent: nil, inverse_of: false

  has_many :template_schema_documents,
           ->(e) { where(uuid: (e.template_schema.presence || e.template.schema).pluck('attachment_uuid')) },
           through: :template, source: :documents_attachments

  scope :active, -> { where(archived_at: nil) }
  scope :pending, -> { joins(:submitters).where(submitters: { completed_at: nil }).group(:id) }
  scope :completed, lambda {
    where.not(Submitter.where(Submitter.arel_table[:submission_id].eq(Submission.arel_table[:id])
     .and(Submitter.arel_table[:completed_at].eq(nil))).select(1).arel.exists)
  }
  scope :declined, -> { joins(:submitters).where.not(submitters: { declined_at: nil }).group(:id) }
  scope :expired, -> { where(expire_at: ..Time.current) }

  enum :source, {
    invite: 'invite',
    bulk: 'bulk',
    api: 'api',
    embed: 'embed',
    link: 'link'
  }, scope: false, prefix: true

  enum :submitters_order, {
    random: 'random',
    preserved: 'preserved'
  }, scope: false, prefix: true

  def expired?
    expire_at && expire_at <= Time.current
  end

  def audit_trail_url
    return if audit_trail.blank?

    ActiveStorage::Blob.proxy_url(audit_trail.blob)
  end
  alias audit_log_url audit_trail_url

  def combined_document_url
    return if combined_document.blank?

    ActiveStorage::Blob.proxy_url(combined_document.blob)
  end
end
