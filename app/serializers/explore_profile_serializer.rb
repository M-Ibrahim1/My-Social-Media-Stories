class ExploreProfileSerializer < ActiveModel::Serializer
  attributes :name, :gender, :profile_picture_url, :email, :bio, :status

  # Including profile picture URL
  def profile_picture_url
    object.profile_picture.attached? ? Rails.application.routes.url_helpers.rails_blob_path(object.profile_picture, only_path: true) : nil
  end

  # Including email and bio only if the user is being followed
  def email
    @instance_options[:following] ? object.email : nil
  end

  def bio
    @instance_options[:following] ? object.bio : nil
  end

  # Status based on following status
  def status
    @instance_options[:following] ? I18n.t('failure.follow.currently_following') : I18n.t('failure.follow.currently_not_following')
  end
end
