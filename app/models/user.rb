# User model with Devise authentication and feature/notification settings
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :diaries, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :health_logs, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy

  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :expense_target,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :notify_schedule_before,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  # Label for the current user shown in the sidebar/menu; falls back to the
  # email when no name has been set.
  def display_name
    name.presence || email
  end
end
