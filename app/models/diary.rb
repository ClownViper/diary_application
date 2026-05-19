class Diary < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }

  has_one_attached :image
  validate :validate_image_attachment

  after_initialize do
    self.date ||= Date.current
  end

  private

  def validate_image_attachment
    return unless image.attached?

    allowed_types = ["image/png", "image/jpg", "image/jpeg", "image/webp"]
    unless allowed_types.include?(image.content_type)
      errors.add(:image, "はPNG、JPG、JPEG、WEBPのみ対応しています")
    end

    if image.blob.byte_size > 10.megabytes
      errors.add(:image, "は10MBまでです")
    end
  end
end