class StoriesController < ApplicationController
  before_action :authenticate_user!

  # Definfing the action for "POST /stories"
  def create
    @story = current_user.stories.new(story_params)
    if @story.save
      render json: {
      message: 'Story created successfully',
      story: {
        id: @story.id,
        text: @story.text,
        media_url: @story.media.attached? ? url_for(@story.media) : nil
      }
    }, status: :created
    else
      render json: { errors: @story.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Definfing the action for "GET /stories/active"
  def active
    stories = Story.where(user_id: current_user.following.ids).where('expires_at > ?', Time.current)
    render json: stories, status: :ok
  end

  private

  def story_params
    params.require(:story).permit(:text, :media)
  end
end
