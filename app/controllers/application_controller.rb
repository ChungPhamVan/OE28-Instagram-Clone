class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_locale

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if user_signed_in?

    store_location
    flash[:danger] = t "users.logged_in_user.please_log_in"
    redirect_to login_url
  end

  def bookmark_like_params
    params.permit :likeable_id, :type_action, :likeable_type
  end

  def object_exists
    object_class = Object.const_get bookmark_like_params[:likeable_type]
    @object = object_class.find_by id: bookmark_like_params[:likeable_id].to_i
    return if @object

    flash[:danger] = t "bookmarks.find_post.not_find_post"
    redirect_to root_url
  end

  def display_post? user
    relationship = Relationship.find_by followed_id: user.id, follower_id: current_user.id
    user.public_mode? || (relationship.present? && relationship.accept?)
  end

  def find_notifications_by_relationship relationship
    Notification.get_by_all relationship.follower_id, relationship.followed_id,
                             Settings.notification.request
  end
end
