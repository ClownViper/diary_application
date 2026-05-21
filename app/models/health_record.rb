class HealthRecord < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }
  validates :weight, numericality: { greater_than: 0, allow_nil: true }
  validates :height, numericality: { greater_than: 0, allow_nil: true }
  validates :body_temperature, numericality: { greater_than: 0, allow_nil: true }
  validates :systolic_pressure, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :diastolic_pressure, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

  after_initialize do
    self.date ||= Date.current
  end
end
