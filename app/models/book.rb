# Reading log model
class Book < ApplicationRecord
  include ImageAttachable
  include Searchable

  searchable_by :title, :author, :memo

  belongs_to :user

  # Cover image attachment
  has_one_attached :cover

  # Status enum definition
  enum :status, { unread: 0, reading: 1, finished: 2 }

  validates :title, presence: true
  validates :memo, length: { maximum: 300 }
  validates :status, presence: true
  validate :validate_cover_attachment

  def self.status_select_options
    statuses.keys.map { |k| [ I18n.t("books.status_labels.#{k}"), k ] }
  end

  def status_label
    I18n.t("books.status_labels.#{status}")
  end

  private

  def validate_cover_attachment
    validate_image(cover, :cover)
  end
end
