# Health log model (weight and condition tracking)
class HealthLog < ApplicationRecord
  include DateDefaultable
  include Searchable

  searchable_by :memo

  after_initialize { self.condition ||= 3 }

  belongs_to :user

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: :taken }
  validates :weight, numericality: { greater_than: 0, allow_nil: true }
  validates :condition, inclusion: { in: 1..5, allow_nil: true }
  validates :memo, length: { maximum: 100 }

  def self.condition_labels
    (1..5).index_with { |i| I18n.t("health_logs.condition_labels.#{i}") }
  end

  def condition_label
    I18n.t("health_logs.condition_labels.#{condition}")
  end
end
