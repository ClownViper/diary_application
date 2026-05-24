class Diary < ApplicationRecord
  include DateDefaultable
  include ImageAttachable

  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }

  has_one_attached :image
  validate :validate_image_attachment

  private

  def validate_image_attachment
    validate_image(image, :image)
  end
end