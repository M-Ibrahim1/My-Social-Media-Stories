module Api
  class FollowsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user, only: %i[follow unfollow]

    # Defining the action for following a user
    def follow
      if current_user.id == @user.id
        render json: { error: "You can't follow yourself" }, status: :unprocessable_entity
      elsif current_user.following.exists?(@user.id)
        render json: { error: "Already following this user" }, status: :unprocessable_entity
      else
        begin
          current_user.following << @user
          render json: { message: "Successfully followed user", user: @user }, status: :ok
        rescue ActiveRecord::RecordNotUnique
          render json: { error: "You are already following this user" }, status: :unprocessable_entity
        end
      end
    end

    # Defining the action for unfollowing a user
    def unfollow
      if current_user.id == @user.id
        render json: { error: "You can't unfollow yourself" }, status: :unprocessable_entity
      elsif current_user.following.exists?(@user.id)
        current_user.following.destroy(@user)
        render json: { message: "Successfully unfollowed user", user: @user }, status: :ok
      else
        render json: { error: "You are not following this user" }, status: :unprocessable_entity
      end
    end

    #private

    # def set_user
    #   @user = User.find(params[:id])
    # rescue ActiveRecord::RecordNotFound
    #   render json: { error: "User not found" }, status: :not_found
    # end
  end
end
