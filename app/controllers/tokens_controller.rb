class TokensController < ApplicationController
  def refresh
    refresh_token = params[:refresh_token]

    # Decoding and verifying the refresh token
    begin
      decoded_token = JWT.decode(refresh_token, Rails.application.secret_key_base).first
      user = User.find_by(id: decoded_token['user_id'])
    rescue JWT::ExpiredSignature
      return render json: { error: 'Refresh token expired' }, status: :unauthorized
    rescue JWT::DecodeError
      return render json: { error: 'Invalid refresh token' }, status: :unauthorized
    end

    if user&.refresh_token == refresh_token
      # If the refresh token has expired or is NULL then we will refresh both tokens, else we only refresh the access token.
      new_access_token = user.generate_access_token
      new_refresh_token = user.refresh_token_expired? ? user.generate_refresh_token : nil

      render json: { access_token: new_access_token, refresh_token: new_refresh_token }.compact, status: :ok
    else
      render json: { error: 'Invalid refresh token' }, status: :unauthorized
    end
  end
end
