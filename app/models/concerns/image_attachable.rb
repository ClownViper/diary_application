# Shared concern: validation logic for image attachments
# Include in models that have image attachments (Diary, Book, etc.)
module ImageAttachable
  extend ActiveSupport::Concern

  ALLOWED_IMAGE_TYPES = %w[image/png image/jpg image/jpeg image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  private

  def validate_image(attachment, field_name)
    return unless attachment.attached?

    errors.add(field_name, :invalid_image_type) unless ALLOWED_IMAGE_TYPES.include?(attachment.content_type)
    errors.add(field_name, :image_too_large) if attachment.blob.byte_size > MAX_IMAGE_SIZE
  end
end
