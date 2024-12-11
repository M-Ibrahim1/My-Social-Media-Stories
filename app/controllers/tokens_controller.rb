class TokensController < ApplicationController
  def refresh
    refresh_token = params[:refresh_token]

    # Decoding and verifying the refresh token using TokenService
    decoded_token = TokenService.decode_token(refresh_token)
    return my_failure_response(message: I18n.t('authentication.invalid_refresh_token'), status: :unauthorized) unless decoded_token

    user = User.find_by(id: decoded_token['user_id'])

    if user && user.refresh_token == refresh_token
      # Refresh the access token
      new_access_token = TokenService.generate_access_token(user)
      new_refresh_token = TokenService.refresh_token_expired?(refresh_token) ? TokenService.generate_refresh_token(user) : nil

      return my_success_response(
        message: I18n.t('authentication.refresh_success'),
        data: { access_token: new_access_token, refresh_token: new_refresh_token }.compact
      )
    else
      return my_failure_response(message: I18n.t('authentication.invalid_refresh_token'), status: :unauthorized)
    end
  end
end
