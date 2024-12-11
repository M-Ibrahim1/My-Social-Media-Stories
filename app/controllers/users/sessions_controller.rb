class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by_email(params[:email])

    if user&.valid_password?(params[:password])
      # Check if the existing refresh token is valid (not missing and not expired), if not then generate a new one
      refresh_token = user.refresh_token.present? && !TokenService.refresh_token_expired?(user.refresh_token) ? user.refresh_token : TokenService.generate_refresh_token(user)

      # Always generate a new access token
      access_token = TokenService.generate_access_token(user)

      # Return the access token and refresh token in the response
      return my_success_response(
        message: I18n.t('success.user.login.success'),
        data: { user: user, access_token: access_token, refresh_token: refresh_token }
      )
    else
      return my_failure_response(message: I18n.t('success.user.login.invalid_credentials'), status: :unauthorized)
    end
  end
end
