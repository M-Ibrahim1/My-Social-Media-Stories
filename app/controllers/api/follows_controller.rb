module Api
  class FollowsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user, only: %i[follow unfollow]

    # Defining the action for following a user
    def follow
      if current_user.id == @user.id
        return my_failure_response(message: I18n.t('failure.follow.self_following'))
      elsif current_user.following.exists?(@user.id)
        return my_failure_response(message: I18n.t('failure.follow.already_following'))
      else
        begin
          current_user.following << @user
          return my_success_response(
            message: I18n.t('success.follow.message'),
            data: {
              name: @user.name,
              profile_picture_url: @user.profile_picture.attached? ? rails_blob_path(@user.profile_picture, only_path: true) : nil,
              email: @user.email,
              gender: @user.gender
          })
        rescue ActiveRecord::RecordNotUnique
          return my_failure_response(message: I18n.t('failure.follow.already_following'))
        end
      end
    end

    # Defining the action for unfollowing a user
    def unfollow
      if current_user.id == @user.id
        return my_failure_response(message: I18n.t('failure.unfollow.self_unfollowing'))
      elsif current_user.following.exists?(@user.id)
        current_user.following.destroy(@user)
        return my_success_response(
          message: I18n.t('success.unfollow.message'),
          data: {
              name: @user.name,
              profile_picture_url: @user.profile_picture.attached? ? rails_blob_path(@user.profile_picture, only_path: true) : nil
          })
      else
        return my_failure_response(message: I18n.t('success.unfollow.not_following'))
      end
    end
  end
end
