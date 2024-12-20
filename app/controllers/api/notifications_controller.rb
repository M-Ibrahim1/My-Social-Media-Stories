module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_user!

    # Defining the action to list notifications for the current user
    def index
      notifications = current_user.notifications.order(created_at: :desc)
      return my_success_response(message: I18n.t('success.notification.index'), data: notifications.map { |notification| serialize_notification(notification) })
    end

    # Defining the action to mark notifications as read
    def mark_as_read
      notification = current_user.notifications.find_by(id: params[:id])

      if notification.nil?
        return my_failure_response(message: I18n.t('success.notification.not_found'), status: :not_found)
      end

      if notification.read_at.present?
        return my_failure_response(message: I18n.t('success.notification.already_read'))
      end

      notification.update(read_at: Time.current)
      return my_success_response(message: I18n.t('success.notification.mark_as_read'), data: serialize_notification(notification))
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
