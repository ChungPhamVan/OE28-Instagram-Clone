class Post < ApplicationRecord
  include PostConcern

  POST_PARAMS = [:description, images: []].freeze

  belongs_to :user
  has_many :post_hashtags, dependent: :destroy
  has_many :hashtags, through: :post_hashtags
  has_many_attached :images
  has_many :bookmark_likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy

  delegate :name, :username, to: :user, prefix: :user

  validates :user_id, presence: true
  validates :images, content_type: {in: Settings.post.content_type,
                                    message: I18n.t("must_be_valid_format")},
    size: {less_than: Settings.post.max_picture_size.megabytes,
           message: I18n.t("less_than_max_size")}
  validate :image_presence

  scope :order_by_created_at, ->{order created_at: :desc}
  scope :order_by_updated_at, ->{order updated_at: :desc}
  scope :order_by_description, ->{order :description}
  scope :feed, (lambda do |user_id|
                  where(user_id: Relationship.following_ids(user_id))
                  .or(where(user_id: user_id))
                end)
  after_commit :add_hashtags, on: %i(create update)

  scope :bookmarking_by_user, (lambda do |user_id|
    joins(bookmark_likes: :user).where(
      "bookmark_likes.type_action": Settings.bookmark_like.bookmark,
      "users.id": user_id
    )
  end)
  scope :feed, (lambda do |user_id|
                  where(user_id: Relationship.following_ids(user_id))
                  .or(where(user_id: user_id))
                end)

  scope :search_by_hashtag, (lambda do |sample_string|
    joins(post_hashtags: :hashtag).where(
      "hashtags.name LIKE :search", search: "%#{sample_string}%"
    ).distinct
  end)
  scope :search_by_description_username, (lambda do |sample_string|
    joins(:user).where(
      "users.username LIKE :search OR description LIKE :search",
        search: "%#{sample_string}%"
    )
  end)

  def likers? user
    User.likers_to_likeable(id, Post.name).include? user
  end

  def top_comments
    comments.top(id)
  end

  private

  def image_presence
    errors.add :images, I18n.t("image_cant_be_blank") unless images.attached?
  end
end
