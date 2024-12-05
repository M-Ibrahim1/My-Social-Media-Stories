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
    # Fetching only those stories which have not expired yet
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
      return
    else
      my_failure_response(message: "Failed to delete the story...")
      return
    end
  end

  # Defining the action for "GET /stories/my_stories"
  def my_stories
    # Fetching only those stories which have not expired yet
    stories = current_user.stories
                          .where('expires_at > ?', Time.current)
                          .select(:id, :text, :created_at, :expires_at)
    render json: stories.map { |story| story.as_json.merge(media_url: story.media.attached? ? url_for(story.media) : nil) }, status: :ok
    return
  end


  # Defining the action for "POST /stories/:id/view"
  def log_view
    story = Story.find_by(id: params[:id])

    # Handling the case when the story is not found
    if story.nil?
      my_failure_response(message: "Requested story not found!", status: :not_found)
      return
    end

    # Handling the case when the story is expired and/or when the logged-in user is the owner of the story
    if story.expires_at <= Time.current
      if story.user_id == current_user.id
        my_failure_response(message: "This story belongs to you, but it is expired!", status: :forbidden)
        return
      else
        my_failure_response(message: "The requested story is expired!", status: :forbidden)
        return
      end
    else
      if story.user_id == current_user.id
        my_success_response(
          message: "This story belongs to you!",
          data: {
            id: story.id,
            text: story.text,
            created_at: story.created_at,
            expires_at: story.expires_at,
            media_url: story.media.attached? ? url_for(story.media) : nil
          }
        )
        return
      end
    end

    # Checking if the logged-in user has already viewed the story
    existing_view = story.views.find_by(viewer: current_user)
    if existing_view
      my_success_response(message: "View already logged/noted!", data: { story_id: story.id })
      return
    else
      # Creating a new view record
      view = story.views.create(viewer: current_user)
      if view.persisted?
        my_success_response(message: "View successfully logged/noted!", data: { story_id: story.id, viewer_id: current_user.id }, status: :created)
        return
      else
        my_failure_response(message: "Failed to log/note view!", errors: view.errors.full_messages)
        return
      end
    end
  end

  # Defining the action for "GET /stories/:id/view_count"
  def view_count
    story = Story.find_by(id: params[:id])

    if story.nil?
      my_failure_response(message: "Requested story not found!", status: :not_found)
      return
    end

    view_count = story.views.count # Getting the total number of views for the story
    render json: { story_id: story.id, view_count: view_count }, status: :ok
    return
  end


  # Defining the action for "GET /stories/:id/viewers"
  def viewers
    story = Story.find_by(id: params[:id])

    if story.nil?
      my_failure_response(message: "Requested story not found!", status: :not_found)
      return
    end

    viewers = story.viewers # Getting all the users who have viewed this story
    render json: viewers, status: :ok
    return
  end


  private

  def story_params
    params.require(:story).permit(:text, :media)
  end
end
