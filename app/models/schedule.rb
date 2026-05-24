# スケジュールモデル
class Schedule < ApplicationRecord
  include DateDefaultable

  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :memo, length: { maximum: 200 }
end
