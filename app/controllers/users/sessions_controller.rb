# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # def create
  #   user = User.find_by_email(params[:email])
  #   if user&.valid_password?(params[:password])
  #     token = user.generate_jwt
  #     render json: { user: user, token: token }, status: :ok
  #   else
  #     render json: { error: 'Invalid credentials' }, status: :unauthorized
  #   end
  # end

  def create
    user = User.find_by_email(params[:email])

    if user&.valid_password?(params[:password])
      # Check if the existing refresh token is valid (not missing and not expired), if not then generate a new one
      refresh_token = user.refresh_token.present? && !user.refresh_token_expired? ? user.refresh_token : user.generate_refresh_token

      # Always generate a new access token
      access_token = user.generate_access_token

      # Return the access token and refresh token in the response
      return render json: { user: user, access_token: access_token, refresh_token: refresh_token }, status: :ok
    else
      return my_failure_response(message: "Invalid credentials, login stopped!", status: :unauthorized)
      #render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
