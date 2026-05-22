FactoryBot.define do
  factory :category do
    association :user
    sequence(:name) { |n| "カテゴリ#{n}" }
    color { "#4B5563" }
  end
end
