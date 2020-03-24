module NotificationsHelper
  def get_post_user notification
    return notification.sender unless notification.post

    notification.post
  end

  def exists_notifications?
    notifications = current_user.passive_notifications.order_by_created_at
    notifications.present?
  end

  def patial_notification
    notifications = current_user.passive_notifications
                                .order_by_created_at
                                .page(params[:page])
                                .per Settings.user.previews_per_page
    render partial: "notifications/notification", collection: notifications
  end

  def mark_read notification
    notification.read? ? "read" : ""
  end

  def count_unread_notif
    count_notif = current_user.passive_notifications.unread.size
    count_notif if count_notif.positive?
  end

  def render_type_notifications notification
    case notification.type_notif
    when Settings.notification.type_follow
      render "notifications/type_notif/follow_notif"
    when Settings.notification.type_like
      render "notifications/type_notif/like_notif"
    when Settings.notification.type_comment
      render "notifications/type_notif/comment_notif"
    when Settings.notification.type_reply
      render "notifications/type_notif/reply_notif"
    when Settings.notification.type_like_comment
      render "notifications/type_notif/like_comment_notif"
    when Settings.notification.type_mention
      render "notifications/type_notif/mention_notif"
    end
  end
end
