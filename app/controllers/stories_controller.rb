class StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :if_story_not_yours, only: [:destroy, :view_count, :viewers]
  before_action :find_story_by_params, only: [:destroy, :log_view, :view_count, :viewers]

  # Defining the action for "POST /stories"
  def create
    story = current_user.stories.new(story_params)
    if story.save
      return my_success_response(
        message: I18n.t('success.story.create'),
        data: {
          id: story.id,
          text: story.text,
          media_url: story.media.attached? ? url_for(story.media) : nil
        },
        status: :created
      )
    else
      return my_failure_response(message: I18n.t('failure.story.create'), errors: @story.errors.full_messages)
    end
  end

  # Defining the action for "GET /stories/active"
  def active
    # Fetching only those stories which have not expired yet
    stories = Story.where(user_id: current_user.following.ids)
                   .where('expires_at > ?', Time.current)
                   .select(:id, :user_id, :text, :created_at, :expires_at)
    return my_success_response(
      message: I18n.t('success.story.retrieve'),
      data: stories.map do |story|
        story.as_json.merge(media_url: story.media.attached? ? url_for(story.media) : nil)
      end
    )
  end

  # Defining the action for "DELETE /stories/:id"
  def destroy
    if @story.destroy
      return my_success_response(
        message: I18n.t('success.story.delete_success'),
        data: {
          id: @story.id,
          text: @story.text,
          created_at: @story.created_at,
          media_url: @story.media.attached? ? url_for(@story.media) : nil
        })
    else
      return my_failure_response(message: I18n.t('failure.story.delete_failure'))
    end
  end

  # Defining the action for "GET /stories/my_stories"
  def my_stories
    # Fetching only those stories which have not expired yet
    stories = current_user.stories
                          .where('expires_at > ?', Time.current)
                          .select(:id, :text, :created_at, :expires_at)
    return my_success_response(
      message: I18n.t('success.story.retrieve'),
      data: stories.map do |story|
        story.as_json.merge(media_url: story.media.attached? ? url_for(story.media) : nil)
      end
    )
  end

  # Defining the action for "POST /stories/:id/view"
  def log_view
    # Handling the case when the story is expired and/or when the logged-in user is the owner of the story
    if @story.expires_at <= Time.current
      message = @story.user_id == current_user.id ? I18n.t('failure.story.your_expired') : I18n.t('failure.story.expired')
      return my_failure_response(message: message, status: :forbidden)
    end

    # Check if the logged-in user is the owner of the story
    if @story.user_id == current_user.id
      return my_success_response(
        message: I18n.t('success.story.yours'),
        data: {
          id: @story.id,
          text: @story.text,
          created_at: @story.created_at,
          expires_at: @story.expires_at,
          media_url: @story.media.attached? ? url_for(@story.media) : nil
        }
      )
    end

    # Checking if the logged-in user has already viewed the story
    existing_view = @story.views.find_by(viewer: current_user)
    if existing_view
      return my_success_response(message: I18n.t('success.view.already_logged'), data: { story_id: @story.id })
    else
      # Creating a new view record
      view = @story.views.create(viewer: current_user)
      if view.persisted?
        Notification.create!(
        recipient: @story.user, # Story owner
        actor: current_user,   # Viewer
        story: @story,
        action: 'viewed')
        return my_success_response(message: I18n.t('success.view.logged'), data: { story_id: @story.id, viewer_id: current_user.id }, status: :created)
      else
        return my_failure_response(message: I18n.t('failure.view.failure'), errors: view.errors.full_messages)
      end
    end
  end

  # Defining the action for "GET /stories/:id/view_count"
  def view_count
    view_count = @story.views.count # Getting the total number of views for the story
    return my_success_response(
      message: I18n.t('success.view.show'),
      data: { story_id: @story.id, view_count: view_count }
    )
  end

  # Defining the action for "GET /stories/:id/viewers"
  def viewers
    viewers = @story.viewers.select(:id, :name).map do |viewer|
      {
        id: viewer.id,
        name: viewer.name,
        profile_picture_url: viewer.profile_picture.attached? ? url_for(viewer.profile_picture) : nil
      }
    end
    return my_success_response(message: I18n.t('success.view.viewers'), data: viewers)
  end

  private

  def story_params
    params.require(:story).permit(:text, :media)
  end

  def if_story_not_yours
    if @story.user_id != current_user.id
      return my_failure_response(message: I18n.t('failure.story.not_yours'), status: :forbidden)
    end
  end

  def find_story_by_params
    @story = Story.find_by(id: params[:id])
    if @story.nil?
      return my_failure_response(message: I18n.t('failure.story.not_found'), status: :not_found)
    end
  end
end
