class Relationship < ApplicationRecord
  enum status: {accept: 0, un_accept: 1}

  belongs_to :follower, class_name: User.name
  belongs_to :followed, class_name: User.name

  validates :followed_id, presence: true
  validates :follower_id, presence: true

  scope :following_ids, (lambda do |user_id|
    select(:followed_id).where(follower_id: user_id).accept
  end)
end
