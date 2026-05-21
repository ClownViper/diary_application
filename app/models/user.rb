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
end
