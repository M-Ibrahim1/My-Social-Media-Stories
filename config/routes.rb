Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations', # Devise's registrations controller, url-> http://localhost:3000/users (request type: POST)
    sessions: 'users/sessions',           # Device's sessions controller for login, url-> http://localhost:3000/users/sign_in (request type: POST)
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

  post 'token/refresh', to: 'tokens#refresh' #url-> http://localhost:3000/token/refresh (request type: POST)

  resources :stories, only: [:create] do
    collection do
      get 'active'
    end
  end

  # post 'stories', to: 'stories#create'
  # get 'stories/active', to: 'stories#active'

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
