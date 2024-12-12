class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :bio, :gender, :profile_picture_url

  def profile_picture_url
    object.profile_picture.attached? ? Rails.application.routes.url_helpers.rails_blob_path(object.profile_picture, only_path: true) : nil
  end
end
