# 体重・体調ログモデル
class HealthLog < ApplicationRecord
  include DateDefaultable

  after_initialize { self.condition ||= 3 }

  belongs_to :user

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }
  validates :weight, numericality: { greater_than: 0, allow_nil: true }
  validates :condition, inclusion: { in: 1..5, allow_nil: true }
  validates :memo, length: { maximum: 100 }

  # 体調レベルのラベル
  CONDITION_LABELS = {
    1 => "とても悪い",
    2 => "悪い",
    3 => "普通",
    4 => "良い",
    5 => "とても良い"
  }.freeze

  def condition_label
    CONDITION_LABELS[condition]
  end
end
