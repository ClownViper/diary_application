FactoryBot.define do
  factory :expense do
    association :user
    sequence(:date) { |n| Date.today - n.days }
    name   { Faker::Commerce.product_name }
    amount { Faker::Number.between(from: 100, to: 50_000) }
    memo   { nil }
  end
end
