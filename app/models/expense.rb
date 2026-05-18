class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  validates :name, presence: true
  validates :amount, presence: true,
                      numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  after_initialize do
    self.date ||= Date.current
  end
end