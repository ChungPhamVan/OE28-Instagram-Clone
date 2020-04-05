require "rails_helper"

RSpec.describe Comment, type: :model do
  let!(:user){FactoryBot.create :user}
  let!(:post){FactoryBot.create :post, user_id: user.id}
  subject {FactoryBot.build :comment, user_id: user.id, post_id: post.id}

  let!(:u1) { FactoryBot.create :user, name: "andrew", username: "andrewharm" }
  let!(:u2) { FactoryBot.create :user, name: "fork", username: "forkeating" }
  let!(:u3) { FactoryBot.create :user, name: "maxim", username: "heplaying" }
  let!(:u4) { FactoryBot.create :user, name: "kelly", username: "shedrinking" }

  let!(:p1) { FactoryBot.create :post, user_id: u1.id }
  let!(:p2) { FactoryBot.create :post, user_id: u2.id }
  let!(:p3) { FactoryBot.create :post, user_id: u3.id }

  let!(:c1) { FactoryBot.create :comment, user_id: u2.id, post_id: p1.id }
  let!(:c2) { FactoryBot.create :comment, user_id: u1.id, post_id: p2.id }
  let!(:c3) { FactoryBot.create :comment, user_id: u4.id, post_id: p1.id, parent_id: c1.id }
  let!(:c4) { FactoryBot.create :comment, user_id: u3.id, post_id: p2.id, parent_id: c2.id }

  describe "Valid Comment" do
    it { expect(subject).to be_valid}
  end

  describe "Associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:parent).class_name("Comment").optional }
    it { is_expected.to have_many(:replies).class_name("Comment").with_foreign_key("parent_id").dependent(:destroy) }
    it { is_expected.to have_many(:likes).class_name("BookmarkLike").with_foreign_key("likeable_id").dependent(:destroy) }
  end

  describe "Delegates" do
    it { is_expected.to delegate_method(:username).to(:user).with_prefix(:user) }
    it { is_expected.to delegate_method(:user).to(:post).with_prefix(:post_owner) }
    it { is_expected.to delegate_method(:user).to(:parent).with_prefix(:parent) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:content).with_message(I18n.t("errors_blank")) }
  end

  describe "Scopes" do
    context "Orders" do
      it { expect(Comment.order_by_created_at).to eq [c1, c2, c3, c4] }
    end

    context "Tops" do
      it { expect(Comment.top p1.id).to eq [c1, c3] }
      it { expect(Comment.top p2.id).to eq [c2, c4] }
      it { expect(Comment.top p3.id).to eq [] }
    end

    context "Roots" do
      it { expect(Comment.root).to eq [c1, c2] }
    end
  end

  describe "Methods" do
    let!(:l1) { FactoryBot.create :bookmark_like, user_id: u1.id, likeable_id: c1.id, likeable_type: Comment.name }
    let!(:l2) { FactoryBot.create :bookmark_like, user_id: u3.id, likeable_id: c1.id, likeable_type: Comment.name }
    let!(:l3) { FactoryBot.create :bookmark_like, user_id: u2.id, likeable_id: c2.id, likeable_type: Comment.name }

    context "Likers" do
      it { expect(c1.likers? u1).to eq true }
      it { expect(c2.likers? u2).to eq true }
      it { expect(c2.likers? u1).to eq false }
    end
  end
end
