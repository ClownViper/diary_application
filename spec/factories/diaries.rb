FactoryBot.define do
  factory :diary do
    association :user
    sequence(:date) { |n| Date.today - n.days }
    title { Faker::Lorem.sentence(word_count: 3) }
    body  { Faker::Lorem.paragraphs(number: 2).join("\n") }
  end
end
