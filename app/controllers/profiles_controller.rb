class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # Defining the action for "GET /profile"
  def show
    render json: current_user.slice(:email, :name, :bio, :profile_picture, :gender), status: :ok
  end

  # Defining the action for "PUT /profile"
  def update
    if current_user.update(profile_params)
      render json: { user: current_user }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :profile_picture, :gender)
  end
end
