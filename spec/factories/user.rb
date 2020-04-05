FactoryBot.define do
  factory :user do
    username {Faker::Internet.username specifier: Settings.user.username_specifier}
    name {Faker::Name.name}
    website {Faker::Internet.url}
    bio {Faker::Lorem.sentence(word_count: Settings.user.word_count)}
    gender {Settings.user.gender_male}
    role {Settings.user.role_user}
    status {Settings.user.public_mode}
    email {Faker::Internet.email}
    password_digest {BCrypt::Password.create(Settings.user.password_default)}
    after(:build) do |user|
      user.avatar_image.attach(io: File.open(Rails.root.
        join("app", "assets", "images", "default.jpg")),
        filename: "default.jpg")
    end
  end
end
