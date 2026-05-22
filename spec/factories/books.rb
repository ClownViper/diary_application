FactoryBot.define do
  factory :book do
    association :user
    title  { Faker::Book.title }
    author { Faker::Book.author }
    status { :unread }
    memo   { nil }
  end
end
