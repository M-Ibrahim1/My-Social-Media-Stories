module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_user!

    # Defining the action to list notifications for the current user
    def index
      notifications = current_user.notifications.order(created_at: :desc)
      render json: notifications.map { |notification| serialize_notification(notification) }, status: :ok
    end

    # Defining the action to mark notifications as read
    def mark_as_read
      notification = current_user.notifications.find_by(id: params[:id])

      if notification.nil?
        render json: { error: "Notification not found" }, status: :not_found
        return
      end

      notification.update(read_at: Time.current)
      render json: serialize_notification(notification), status: :ok
    end

    private

    # Serializing notification details for rendering in JSON response
    def serialize_notification(notification)
      {
        id: notification.id,
        actor: {
          name: notification.actor.name,
          profile_picture_url: notification.actor.profile_picture.attached? ? rails_blob_path(notification.actor.profile_picture, only_path: true) : nil
        },
        action: notification.action,
        story_id: notification.story_id,
        read_at: notification.read_at,
        created_at: notification.created_at
      }
    end
  end
end
