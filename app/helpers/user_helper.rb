module UserHelper
  def gender_user user
    if user.gender == "female"
      Settings.user.gender_female
    elsif user.gender == "male"
      Settings.user.gender_male
    elsif user.gender == "other"
      Settings.user.gender_other
    end
  end

  def status_account user
    case user.status
    when Settings.user.public_mode_text
      Settings.user.public_mode
    when Settings.user.private_mode_text
      Settings.user.private_mode
    end
  end

  def arr_gender
    User.genders.map do |key, value|
      [key, value]
    end
  end

  def arr_status
    User.statuses.map do |key, value|
      [key.chomp("_user").capitalize, value]
    end
  end

  def display_avatar_image user
    user.avatar_image.attached? ? user.avatar_image : Settings.user.default_avt
  end

  def get_relationship user
    if current_user.following? user
      current_user.active_relationships.find_by followed_id: user.id
    else
      current_user.active_relationships.build
    end
  end

  def follow_unfollow user
    if user_signed_in? && current_user.following?(user)
      "users/unfollow"
    else
      "users/follow"
    end
  end

  def get_status_relationship user
    user.public_mode? ? Settings.relationship.accept : Settings.relationship.un_accept
  end

  def display_gallery? user
    relationship = Relationship.find_by followed_id: user.id, follower_id: current_user.id
    user.public_mode? || (relationship.present? && relationship.accept?)
  end
end
