# Schedule model
class Schedule < ApplicationRecord
  include DateDefaultable
  include Searchable

  searchable_by :title, :memo

  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :memo, length: { maximum: 200 }
end
