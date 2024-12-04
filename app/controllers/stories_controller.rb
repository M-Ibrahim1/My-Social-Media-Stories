class StoriesController < ApplicationController
  before_action :authenticate_user!

  # Definfing the action for "POST /stories"
  def create
    @story = current_user.stories.new(story_params)
    if @story.save
      my_success_response(
        message: "Story created successfully",
        data: {
          id: @story.id,
          text: @story.text,
          media_url: @story.media.attached? ? url_for(@story.media) : nil
        },
        status: :created
      )
    else
      my_failure_response(message: "Failed to create story", errors: @story.errors.full_messages)
    end
  end

  # Definfing the action for "GET /stories/active"
  def active
    stories = Story.where(user_id: current_user.following.ids)
                   .where('expires_at > ?', Time.current)
                   .select(:id, :user_id, :text, :created_at, :expires_at)
    render json: stories.map { |story| story.as_json.merge(media_url: story.media.attached? ? url_for(story.media) : nil) }, status: :ok
  end

  # Defining the action for "DELETE /stories/:id"
  def destroy
    story = Story.find_by(id: params[:id])

    if story.nil?
      my_failure_response(message: "This story does not exist! (either it is already deleted, or it has not been created yet", status: :not_found)
      return
    end

    if story.user_id != current_user.id
      my_failure_response(message: "You can not delete this story because it is not yours!", status: :forbidden)
      return
    end

    if story.destroy
      my_success_response(
        message: "Successfully deleted the story!",
        data: {
          id: story.id,
          text: story.text,
          created_at: story.created_at,
          media_url: story.media.attached? ? url_for(story.media) : nil
        },
        status: :ok
      )
    else
      my_failure_response(message: "Failed to delete the story...")
    end
  end

  # Defining the action for "GET /stories/my_stories"
  def my_stories
    stories = current_user.stories.select(:id, :text, :created_at, :expires_at)
    render json: stories.map { |story| story.as_json.merge(media_url: story.media.attached? ? url_for(story.media) : nil) }, status: :ok
  end

  private

  def story_params
    params.require(:story).permit(:text, :media)
  end
end
