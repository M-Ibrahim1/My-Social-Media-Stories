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

  # Authenticating the user with the JWT Access token
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base).first

      # Checking if the token is an access token
      if decoded_token['type'] != 'access'
        return my_failure_response(message: "Invalid token type!", status: :unauthorized)
      end

      # Finding the user based on the decoded token
      @current_user = User.find_by(id: decoded_token['user_id'])
      return my_failure_response(message: "Not Authorized!", status: :unauthorized) unless @current_user
    rescue JWT::DecodeError, JWT::ExpiredSignature
      return my_failure_response(message: "Not Authorized!", status: :unauthorized)
    end
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return my_failure_response(message: "User not found!", status: :not_found)
  end
end
