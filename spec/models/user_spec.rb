require "rails_helper"

RSpec.describe User, type: :model do
  subject {FactoryBot.build :user}

  describe "Valid User" do
    it { expect(subject).to be_valid}
    it { expect(subject.avatar_image).to be_attached}
  end

  describe "Associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy)}
    it { is_expected.to have_many(:active_relationships).class_name("Relationship").with_foreign_key("follower_id").dependent(:destroy)}
    it { is_expected.to have_many(:passive_relationships).class_name("Relationship").with_foreign_key("followed_id").dependent(:destroy)}
    it { is_expected.to have_many(:following).through(:active_relationships).source(:followed)}
    it { is_expected.to have_many(:followers).through(:passive_relationships).source(:follower)}
    it { is_expected.to have_many(:bookmark_likes).dependent(:destroy)}
    it { is_expected.to have_many(:comments).dependent(:destroy)}
    it { is_expected.to have_many(:active_notifications).class_name("Notification").with_foreign_key("sender_id").dependent(:destroy)}
    it { is_expected.to have_many(:passive_notifications).class_name("Notification").with_foreign_key("receiver_id").dependent(:destroy)}
    it { is_expected.to have_many(:senders).through(:passive_notifications).source(:sender)}
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:role).with_values([:user, :admin])}
    it { is_expected.to define_enum_for(:gender).with_values([:female, :male, :other])}
    it { is_expected.to define_enum_for(:status).with_values([:public_mode, :private_mode])}
  end

  describe "has secure password" do
    it { is_expected.to have_secure_password }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:username).with_message(I18n.t("errors_blank")) }
    it { is_expected.to validate_length_of(:username).is_at_least(Settings.user.min_length_username).is_at_most(Settings.user.max_length_username)}
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive.with_message(I18n.t("errors_taken")) }

    it { is_expected.to validate_presence_of(:name).with_message(I18n.t("errors_blank")) }
    it { is_expected.to validate_length_of(:name).is_at_most(Settings.user.max_length_name)}

    it { is_expected.to validate_presence_of(:email).with_message(I18n.t("errors_blank")) }
    it { is_expected.to validate_length_of(:email).is_at_most(Settings.user.max_length_email)}
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message(I18n.t("errors_taken")) }
    it { is_expected.to allow_value("chungpham@gmail.com").for(:email) }

    it { is_expected.to validate_presence_of(:password).with_message(I18n.t("errors_blank")) }
    it { is_expected.to validate_length_of(:password).is_at_least(Settings.user.min_length_password) }
    it { is_expected.to validate_confirmation_of(:password) }
  end

  describe "Scopes" do
    let!(:u1) { FactoryBot.create :user, name: "andrew", username: "andrewharm" }
    let!(:u2) { FactoryBot.create :user, name: "fork", username: "forkeating" }
    let!(:u3) { FactoryBot.create :user, name: "maxim", username: "heplaying" }
    let!(:u4) { FactoryBot.create :user, name: "kelly", username: "shedrinking" }

    context "search user by name and username" do
      it {expect(User.search_by_name_username("andrew")).to eq [u1]}
      it {expect(User.search_by_name_username("r")).to eq [u1, u2, u4]}
      it {expect(User.search_by_name_username("ing")).to eq [u2, u3, u4]}
      it {expect(User.search_by_name_username("eva")).to eq []}
    end
  end
end
