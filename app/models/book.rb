# 読書ログモデル
class Book < ApplicationRecord
  include ImageAttachable

  belongs_to :user

  # 表紙画像
  has_one_attached :cover

  # ステータス定義
  enum :status, { unread: 0, reading: 1, finished: 2 }

  STATUS_LABELS = {
    "unread" => "未読",
    "reading" => "読書中",
    "finished" => "読了"
  }.freeze

  validates :title, presence: true
  validates :memo, length: { maximum: 300 }
  validates :status, presence: true
  validate :validate_cover_attachment

  def status_label
    STATUS_LABELS[status]
  end

  private

  def validate_cover_attachment
    validate_image(cover, :cover)
  end
end
