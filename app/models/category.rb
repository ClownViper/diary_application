# Category model for classifying expenses
class Category < ApplicationRecord
  HEX_COLOR = /\A#[0-9A-Fa-f]{6}\z/

  belongs_to :user
  has_many :expenses, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true,
                    format: { with: HEX_COLOR, message: :invalid_hex }
end