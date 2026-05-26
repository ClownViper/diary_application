FactoryBot.define do
  factory :health_log do
    association :user
    sequence(:date) { |n| Date.today - n.days }
    weight      { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    condition   { Faker::Number.between(from: 1, to: 5) }
    sleep_hours { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    temperature { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    memo        { nil }
  end
end
