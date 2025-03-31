Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions'
  }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  post '/create_checkout_session', to: 'payments#create_checkout_session'
  get '/success', to: 'payments#success'

  mount ActionCable.server => '/cable'
  resources :matches do
    member do
      put 'final_scores'
    end
    resources :chat_rooms do
      resources :messages, only: [:create]
    end
  end
  resources :chat_rooms do
    member do
      post :enter
      post :leave
      post :mark_as_read
      post :mark_as_read
    end
  end
  resources :teams do
    delete :remove_player
    put :update_home_course
    get :winner_teams, on: :collection
  end

  resources :matches
  get '/team_match_confirmation', to: 'matches#team_match_confirmation'
  get '/course_handicap_calculation', to: 'matches#course_handicap_calculation'
  put '/update_team', to: 'matches#update_team'
  get '/match_summary', to: 'matches#match_summary'
  get '/edit_scores', to: 'matches#edit_scores'
  post '/submit_scores', to: 'matches#submit_scores'
  get '/match_in_progress', to: 'matches#match_in_progress'
  get '/get_scores', to: 'matches#get_scores'
  put '/confirm_score', to: 'matches#confirm_score'
  put '/final_scores', to: 'matches#final_scores'
  get '/upcoming_matches', to: 'matches#upcoming_matches'

  resources :invitations, only: :create

  resources :magic_links, only: %i[create index]
  get '/faqs', to: 'magic_links#faqs'
  get '/about_the_challenge', to: 'magic_links#about_the_challenge'

  resource :users, only: [] do
    patch :set_online
    patch :set_offline
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get :get_email, to: 'users/registrations#get_email'
    put :add_profile_picture, to: 'users/registrations#add_profile_picture'
    get :sign_up_with_magic_link, to: 'users/registrations#sign_up_with_magic_link'
    get :sign_in_with_magic_link, to: 'users/sessions#sign_in_with_magic_link'
    get :redirect_user, to: 'users/sessions#redirect_user'
    get :personal_information, to: 'users/registrations#personal_information'
    put :update_personal_information, to: 'users/registrations#update_personal_information'
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ('/')
  root to: 'homes#index'
end
