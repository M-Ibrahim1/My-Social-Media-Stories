Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations', # Devise's registrations controller, url-> http://localhost:3000/users (request type: POST)
    sessions: 'users/sessions',           # Devise's sessions controller for login, url-> http://localhost:3000/users/sign_in (request type: POST)
    passwords: 'users/passwords',         # Devise's password recovery controller with the following urls:
                                          # For requesting a password reset-> http://localhost:3000/users/password/new (request type: GET)
                                          # For submitting the request-> http://localhost:3000/users/password (request type: POST)
                                          # For resetting the password-> http://localhost:3000/users/password/edit?reset_password_token=token (request type: GET)
                                          # For submitting the new password-> http://localhost:3000/users/password (request type: PUT / PATCH)
    confirmations: 'users/confirmations'  # For User confirmation via email, url-> http://localhost:3000/users/confirmation?confirmation_token=<TOKEN> (request type: GET)
  }

  # Profile routes
  get '/profile', to: 'profiles#show' #url-> http://localhost:3000/profile (request type: GET)
  put '/profile', to: 'profiles#update' #url-> http://localhost:3000/profile (request type: PUT)
  get '/profile/explore/:id', to: 'profiles#explore' # url-> http://localhost:3000/profile/explore/:id (request type: GET)

  post 'token/refresh', to: 'tokens#refresh' #url-> http://localhost:3000/token/refresh (request type: POST)

  resources :stories, only: [:create, :destroy] do
    collection do
      get 'active'
      get 'my_stories'
    end

    member do
      post 'view', to: 'stories#log_view' # url-> http://localhost:3000/stories/:id/view (request type: POST)
      get 'viewers', to: 'stories#viewers' # url-> http://localhost:3000/stories/:id/viewers (request type: GET)
      get 'view_count', to: 'stories#view_count' # url-> http://localhost:3000/stories/:id/view_count (request type: GET)
    end
  end
  # post 'stories', to: 'stories#create'
  # get 'stories/active', to: 'stories#active'
  # delete 'stories/:id', to: 'stories#destroy'
  # get 'stories/my_stories', to: 'stories#my_stories'
  # post '/stories/:id/view', to: 'stories#log_view', as: :log_story_view

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Routes for follow/unfollow & notifications functionality
  namespace :api do
    resources :notifications, only: [:index] do # url-> http://localhost:3000/api/notifications (request type: GET)
      member do
        post 'mark_as_read' # url-> http://localhost:3000/api/notifications/:id/mark_as_read (request type: POST)
      end
    end
    resources :follows, only: [] do
      member do
        post :follow   # For following a User, url-> http://localhost:3000/api/follows/:id/follow (request type: POST)
        delete :unfollow # For unfollowing a User, url-> http://localhost:3000/api/follows/:id/unfollow (request type: DELETE)
      end
    end
  end
end
