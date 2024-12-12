class ViewSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :story_id

  belongs_to :viewer, serializer: UserSerializer

  def story_id
    object.story_id
  end
end
