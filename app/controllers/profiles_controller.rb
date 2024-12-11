class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :if_user_nil, only: [:explore]
  before_action :self_explore, only: [:explore]

  # Defining the action for "GET /profile"
  def show
    user_data = current_user.slice(:id, :email, :name, :bio, :gender)
    user_data[:profile_picture_url] = rails_blob_path(current_user.profile_picture, only_path: true) if current_user.profile_picture.attached?
    return my_success_response(message: I18n.t('success.user.profile.show'), data: user_data)
  end

  # Defining the action for "PUT /profile"
  def update
    if current_user.update(profile_params)
      user_data = current_user.slice(:id, :email, :name, :bio, :gender)
      user_data[:profile_picture_url] = rails_blob_path(current_user.profile_picture, only_path: true) if current_user.profile_picture.attached?
      return my_success_response(message: I18n.t('success.user.profile.update_success'), data: user_data)
    else
      return my_failure_response(message: I18n.t('success.user.profile.update_failure'), errors: current_user.errors.full_messages)
    end
  end

  # Defining the action for "GET /profile/explore/:id"
  def explore
    following = current_user.following.include?(@user)

    profile_data = {
      name: @user.name,
      gender: @user.gender,
      profile_picture_url: @user.profile_picture.attached? ? rails_blob_path(@user.profile_picture, only_path: true) : nil
    }

    # Adding more profile details if the requested user is being followed by the logged-in user
    if following
      profile_data[:email] = @user.email
      profile_data[:bio] = @user.bio
      profile_data[:status] = I18n.t('failure.follow.currently_following')
    else
      profile_data[:status] = I18n.t('failure.follow.currently_not_following')
    end
    return my_success_response(message: I18n.t('success.user.profile.found'), data: profile_data)
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :profile_picture, :gender)
  end

  def if_user_nil
    @user = User.find_by(id: params[:id])
    if @user.nil?
      return my_failure_response(message: I18n.t('failure.user.not_found'), status: :not_found)
    end
  end

  def self_explore
    if current_user.id == params[:id].to_i
      return my_success_response(message: I18n.t('success.user.profile.explore_self'))
    end
  end
end
