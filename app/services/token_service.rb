class TokenService
  SECRET_KEY = Rails.application.secret_key_base

  # Generate a JWT Access token for a user
  def self.generate_access_token(user)
    payload = {
      user_id: user.id,
      type: 'access',
      exp: 15.minutes.from_now.to_i
    }
    JWT.encode(payload, SECRET_KEY)
  end

  # Generate a JWT Refresh token for a user
  def self.generate_refresh_token(user)
    payload = {
      user_id: user.id,
      type: 'refresh',
      exp: 1.day.from_now.to_i
    }
    new_token = JWT.encode(payload, SECRET_KEY)

    # Save the refresh token in the user record
    user.update(refresh_token: new_token)
    new_token
  end

  # Check if the refresh token has expired
  def self.refresh_token_expired?(refresh_token)
    begin
      decoded_token = JWT.decode(refresh_token, SECRET_KEY).first

      # Ensure the token is a refresh token and check expiration
      return true if decoded_token['type'] != 'refresh'
      Time.at(decoded_token['exp']) < Time.now
    rescue JWT::DecodeError
      true
    end
  end

  # Verify and decode the token
  def self.decode_token(token)
    JWT.decode(token, SECRET_KEY).first
  rescue JWT::DecodeError
    nil
  end
end
