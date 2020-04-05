FactoryBot.define do
  factory :post do
    description {Faker::Lorem.sentence}
    association :user
    after(:build) do |post|
      post.images.attach(io: File.open(Rails.root.
        join("app", "assets", "images", "default.jpg")),
        filename: "default.jpg")
    end
  end
end
