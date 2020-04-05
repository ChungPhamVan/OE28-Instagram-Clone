FactoryBot.define do
  factory :comment do
    content {Faker::Lorem.sentence(word_count: Settings.user.word_count_comment)}
    association :user
    association :post
    trait :with_parent_comment do
      association :parent, factory: :user
    end
  end
end
