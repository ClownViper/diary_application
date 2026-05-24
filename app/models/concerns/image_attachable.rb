# 画像添付バリデーションの共通ロジック
# Diary・Book など画像を持つモデルで include して使う
module ImageAttachable
  extend ActiveSupport::Concern

  ALLOWED_IMAGE_TYPES = %w[image/png image/jpg image/jpeg image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  private

  def validate_image(attachment, field_name)
    return unless attachment.attached?

    unless ALLOWED_IMAGE_TYPES.include?(attachment.content_type)
      errors.add(field_name, "はPNG、JPG、JPEG、WEBPのみ対応しています")
    end

    if attachment.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(field_name, "は10MBまでです")
    end
  end
end
