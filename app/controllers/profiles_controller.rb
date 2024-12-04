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
      my_success_response(message: "Modification successful!", data: user_data)
    else
      my_failure_response(message: "Modification unsuccessful!", errors: current_user.errors.full_messages)
    end
  end

  # Defining the action for "GET /profile/explore/:id"
  def explore
    user = User.find_by(id: params[:id])

    if current_user.id == params[:id].to_i
      my_success_response(message: "This is you. Send a GET request at 'http://localhost:3000/profile' to explore your profile")
      return
    end

    if user.nil?
      my_failure_response(message: "User not found!", status: :not_found)
      return
    end

    following = current_user.following.include?(user)

    profile_data = {
      name: user.name,
      gender: user.gender
    }

    # Adding more profile details if the requested user is being followed by the logged in user
    if following
      profile_data[:email] = user.email
      profile_data[:bio] = user.bio
      profile_data[:status] = "You are currently following this user"
    else
      profile_data[:status] = "You are currently not following this user, follow them to see more details about their profile"
    end

    # Including the profile picture URL too if the requested uer has profile picture attached/uploaded
    profile_data[:profile_picture_url] = rails_blob_path(user.profile_picture, only_path: true) if user.profile_picture.attached?

    my_success_response(message: "User profile found!", data: profile_data)
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :profile_picture, :gender)
  end
end
