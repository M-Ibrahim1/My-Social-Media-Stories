class Users::RegistrationsController < Devise::RegistrationsController
  def create
    user = User.new(user_params)
    if user.save
      # Sending confirmation email
      user.send_confirmation_instructions if user.confirmation_token.present?

      access_token = TokenService.generate_access_token(user)
      refresh_token = TokenService.generate_refresh_token(user)

      user_data = user.slice(:id, :email, :name, :bio, :gender)
      user_data[:profile_picture_url] = rails_blob_path(user.profile_picture, only_path: true) if user.profile_picture.attached?

      my_success_response(
        message: I18n.t('success.user.create.success'),
        data: {
          user: user_data,
          access_token: access_token,
          refresh_token: refresh_token
        },
        status: :created
      )
    else
      return my_failure_response(message: I18n.t('success.user.create.failure'))
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :bio, :profile_picture, :gender)
  end
end
