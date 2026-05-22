# スケジュールモデル
class Schedule < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :memo, length: { maximum: 200 }

  after_initialize do
    self.date ||= Date.current
  end
end
