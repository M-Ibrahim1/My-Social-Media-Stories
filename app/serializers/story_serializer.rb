class StorySerializer < ActiveModel::Serializer
  attributes :id, :user_id, :text, :media_url, :created_at, :expires_at, :active

  belongs_to :user, serializer: UserSerializer

  def media_url
    object.media.attached? ? Rails.application.routes.url_helpers.rails_blob_path(object.media, only_path: true) : nil
  end

  def active
    object.active?
  end
end
