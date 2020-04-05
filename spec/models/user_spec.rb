require "rails_helper"

RSpec.describe User, type: :model do
  subject { FactoryBot.build :user }

  let!(:u1) { FactoryBot.create :user, name: "andrew", username: "andrewharm" }
  let!(:u2) { FactoryBot.create :user, name: "fork", username: "forkeating" }
  let!(:u3) { FactoryBot.create :user, name: "maxim", username: "heplaying" }
  let!(:u4) { FactoryBot.create :user, name: "kelly", username: "shedrinking" }

  let!(:p1) { FactoryBot.create :post, user_id: u1.id }
  let!(:p2) { FactoryBot.create :post, user_id: u2.id }
  let!(:p3) { FactoryBot.create :post, user_id: u3.id }

  describe "Valid User" do
    it { expect(subject).to be_valid }
    it { expect(subject.avatar_image).to be_attached }
  end

  describe "Associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:active_relationships).class_name(Relationship.name).with_foreign_key("follower_id").dependent(:destroy) }
    it { is_expected.to have_many(:passive_relationships).class_name(Relationship.name).with_foreign_key("followed_id").dependent(:destroy) }
    it { is_expected.to have_many(:following).through(:active_relationships).source(:followed) }
    it { is_expected.to have_many(:followers).through(:passive_relationships).source(:follower) }
    it { is_expected.to have_many(:bookmark_likes).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:active_notifications).class_name(Notification.name).with_foreign_key("sender_id").dependent(:destroy) }
    it { is_expected.to have_many(:passive_notifications).class_name(Notification.name).with_foreign_key("receiver_id").dependent(:destroy) }
    it { is_expected.to have_many(:senders).through(:passive_notifications).source(:sender) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:role).with_values([:user, :admin]) }
    it { is_expected.to define_enum_for(:gender).with_values([:female, :male, :other]) }
    it { is_expected.to define_enum_for(:status).with_values([:public_mode, :private_mode]) }
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
    let!(:l1) { FactoryBot.create :bookmark_like, user_id: u1.id, likeable_id: p1.id, likeable_type: Post.name }
    let!(:l2) { FactoryBot.create :bookmark_like, user_id: u3.id, likeable_id: p1.id, likeable_type: Post.name }
    let!(:l3) { FactoryBot.create :bookmark_like, user_id: u2.id, likeable_id: p2.id, likeable_type: Post.name }
    let!(:l4) { FactoryBot.create :bookmark_like, user_id: u4.id, likeable_id: p2.id, likeable_type: Post.name }

    context "Likers" do
      it {expect(User.likers_to_likeable p1.id, p1.class.name).to eq [u1, u3]}
      it {expect(User.likers_to_likeable p2.id, p2.class.name).to eq [u2, u4]}
      it {expect(User.likers_to_likeable p3.id, p3.class.name).to eq []}
    end

    context "Search" do
      it { expect(User.search_by_name_username "andrew").to eq [u1] }
      it { expect(User.search_by_name_username "ing").to eq [u2, u3, u4] }
      it { expect(User.search_by_name_username "eva").to eq [] }
      it { expect(User.search_by_name_username "").to eq [u1, u2, u3, u4] }
    end
  end

  describe "Methods" do
    let!(:b1) { FactoryBot.create :bookmark_like, user_id: u1.id, likeable_id: p1.id, likeable_type: Post.name, type_action: Settings.bookmark_like.bookmark }
    let!(:b2) { FactoryBot.create :bookmark_like, user_id: u1.id, likeable_id: p2.id, likeable_type: Post.name, type_action: Settings.bookmark_like.bookmark }
    let!(:b3) { FactoryBot.create :bookmark_like, user_id: u2.id, likeable_id: p2.id, likeable_type: Post.name, type_action: Settings.bookmark_like.bookmark }

    context "Bookmarking" do
      it { expect(u1.bookmarking? p1).to eq true }
      it { expect(u2.bookmarking? p2).to eq true }
      it { expect(u2.bookmarking? p1).to eq false }
      it { expect(u3.bookmarking? p2).to eq false }
    end
  end
end
