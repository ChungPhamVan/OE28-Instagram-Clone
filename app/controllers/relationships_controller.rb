class RelationshipsController < ApplicationController
  before_action :logged_in_user, :load_user
  before_action :logged_in_user, :load_relationship, only: %i(update destroy)

  def create
    params[:status] = params[:status].to_i
    @relationship = current_user.active_relationships
                                .build relationship_params
    if @relationship.save
      notif = {
        sender: current_user,
        receiver: @user,
        post: nil,
        type_notif: @user.public_mode? ? Settings.notification.follow : Settings.notification.request
      }
      NotificationPushService.new(notif).push_notification unless current_user? @user
    else
      @messages = t ".create_failed"
    end
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def update
    @messages = t ".error_update" unless @relationship.accept!
    @update = {
      notifications: find_notifications_by_relationship(@relationship),
      message_confirmed: t("notifications.active_relationship.confirmed")
    }
    notif = {
      sender: @relationship.followed,
      receiver: @relationship.follower,
      post: nil,
      type_notif: Settings.notification.accept
    }
    NotificationPushService.new(notif).push_notification if current_user? @relationship.followed
    respond_to do |format|
      format.html{redirect_to current_user}
      format.js
    end
  end

  def destroy
    @messages = t ".error_destroy" unless @relationship.destroy
    @notifications = find_notifications_by_relationship @relationship
    respond_to do |format|
      @message_refused = t "notifications.active_relationship.refused"
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def load_user
    @user = if request.post?
              User.find_by id: relationship_params[:followed_id]
            else
              Relationship.find_by(id: params[:id]).followed
            end
    return if @user

    flash[:danger] = t ".invalid_user"
    redirect_to root_path
  end

  def load_relationship
    @relationship = Relationship.find_by(id: params[:id])
    return if @relationship

    respond_to do |format|
      format.html{redirect_to current_user}
      format.js
    end
  end

  def relationship_params
    params.permit :followed_id, :status
  end
end
