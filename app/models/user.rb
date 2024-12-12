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

  has_many :views, foreign_key: :viewer_id, dependent: :destroy
  has_many :viewed_stories, through: :views, source: :story

  has_many :notifications, foreign_key: :recipient_id
  after_commit :clear_confirmation_token, on: :update

  # Overriding confirm to ensure the confirmation token is cleared
  def confirm
    Rails.logger.info "Confirm method called for user: #{email}"
    super
    Rails.logger.info "Confirmed status: #{confirmed?}"
    update_column(:confirmation_token, nil) unless confirmed?
  end

  private

  def clear_confirmation_token
    return unless confirmed? && confirmation_token.present?

    update_column(:confirmation_token, nil)
  end
end
