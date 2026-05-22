FactoryBot.define do
  factory :schedule do
    association :user
    sequence(:date) { |n| Date.today + n.days }
    title { Faker::Lorem.sentence(word_count: 3) }
    memo  { nil }
  end
end
