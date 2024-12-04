class Story < ApplicationRecord
  belongs_to :user
  has_one_attached :media # Attaching media (image/video) via ActiveStorage

  validates :text, presence: true
  validate :validate_media_content_type

  # Ensuring that the story expires after 24 hours
  before_create :set_expiration_time

  def active?
    expires_at > Time.current
  end

  private

  def set_expiration_time
    self.expires_at = 24.hours.from_now
  end

  def validate_media_content_type
    if media.attached? && !media.content_type.in?(%w[image/png image/jpg image/jpeg video/mp4])
      errors.add(:media, 'must be a PNG, JPG, JPEG, or MP4 file')
    end
  end
end
