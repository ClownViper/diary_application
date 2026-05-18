class Diary < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }

  has_one_attached :image
  validates :image, content_type: ["image/png", "image/jpg", "image/jpeg", "image/webp"], size: { less_than: 10.megabytes, message: "10MBまでです" }, allow_blank: true

  after_initialize do
    self.date ||= Date.current
  end
end