class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # Defining the action for "GET /profile"
  def show
    user_data = current_user.slice(:id, :email, :name, :bio, :gender)
    user_data[:profile_picture_url] = rails_blob_path(current_user.profile_picture, only_path: true) if current_user.profile_picture.attached?
    render json: user_data, status: :ok
  end

  # Defining the action for "PUT /profile"
  def update
    if current_user.update(profile_params)
      user_data = current_user.slice(:id, :email, :name, :bio, :gender)
      user_data[:profile_picture_url] = rails_blob_path(current_user.profile_picture, only_path: true) if current_user.profile_picture.attached?
      render json: { user: user_data }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :profile_picture, :gender)
  end
end
