class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Active Storage association for profile picture
  has_one_attached :profile_picture

  # Associations for following other users
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :active_follows, source: :followee

  # Associations for being followed by other users
  has_many :passive_follows, class_name: "Follow", foreign_key: :followee_id, dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  has_many :stories, dependent: :destroy

  after_commit :clear_confirmation_token, on: :update

  # Overriding confirm to ensure the confirmation token is cleared
  def confirm
    Rails.logger.info "Confirm method called for user: #{email}"
    super
    Rails.logger.info "Confirmed status: #{confirmed?}, Token before nilify: #{confirmation_token}"
    update_column(:confirmation_token, nil) unless confirmed?
  end

  # Checking if the refresh token has expired
  def refresh_token_expired?
    begin
      decoded_token = JWT.decode(refresh_token, Rails.application.secret_key_base).first

      # Ensure the token is a refresh token and check expiration
      return true if decoded_token['type'] != 'refresh'
      Time.at(decoded_token['exp']) < Time.now
    rescue JWT::DecodeError
      true
    end
  end

  # Generating a JWT Access token
  def generate_access_token
    payload = {
      user_id: id,
      type: 'access', # Specify the token type
      exp: 15.minutes.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  # Generating a JWT Refresh token
  def generate_refresh_token
    payload = {
      user_id: id,
      type: 'refresh', # Specify the token type
      exp: 1.day.from_now.to_i
    }
    new_token = JWT.encode(payload, Rails.application.secret_key_base)

    # Saving the refresh token in the database
    update(refresh_token: new_token)
    new_token
  end

  private

  def clear_confirmation_token
    return unless confirmed? && confirmation_token.present?

    update_column(:confirmation_token, nil)
  end
end
