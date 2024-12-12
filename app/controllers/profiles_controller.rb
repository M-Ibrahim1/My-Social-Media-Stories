class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :if_user_nil, only: [:explore]
  before_action :self_explore, only: [:explore]

  # Defining the action for "GET /profile"
  def show
    my_success_response(message: I18n.t('success.user.profile.show'), data: ActiveModelSerializers::SerializableResource.new(current_user, serializer: UserSerializer))
  end

  # Defining the action for "PUT /profile"
  def update
    if current_user.update(profile_params)
      user_data = ActiveModelSerializers::SerializableResource.new(current_user, serializer: UserSerializer)
      return my_success_response(message: I18n.t('success.user.profile.update_success'), data: user_data)
    else
      return my_failure_response(message: I18n.t('success.user.profile.update_failure'), errors: current_user.errors.full_messages)
    end
  end

  # Defining the action for "GET /profile/explore/:id"
  def explore
    following = current_user.following.include?(@user)
    profile_data = ActiveModelSerializers::SerializableResource.new(@user, serializer: ExploreProfileSerializer, following: following)
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
