class ApplicationController < ActionController::API
  include ActionController::Helpers

  def my_success_response(message:, data: nil, status: :ok)
    response = { message: message }
    response[:data] = data if data.present?
    render json: response, status: status
  end

  def my_failure_response(message:, errors: nil, status: :unprocessable_entity)
    response = { message: message }
    response[:errors] = errors if errors.present?
    render json: response, status: status
  end

  # Authenticating the user with the JWT Access token using TokenService
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    decoded_token = TokenService.decode_token(token)
    return my_failure_response(message: I18n.t('success.token.expired_or_invalid'), status: :unauthorized) unless decoded_token && decoded_token['type'] == 'access'

    @current_user = User.find_by(id: decoded_token['user_id'])
    return my_failure_response(message: I18n.t('success.token.not_authorized'), status: :unauthorized) unless @current_user
  rescue JWT::DecodeError, JWT::ExpiredSignature
    return my_failure_response(message: I18n.t('success.token.expired_or_invalid'), status: :unauthorized)
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return my_failure_response(message: I18n.t('failure.user.not_found'), status: :not_found)
  end
end
