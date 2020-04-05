FactoryBot.define do
  factory :bookmark_like do
    type_action {Settings.bookmark_like.like}
    association :user
    association :likeable
  end
end
