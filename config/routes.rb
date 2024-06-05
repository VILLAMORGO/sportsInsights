Rails.application.routes.draw do
  get 'intro', to: 'pages#intro'
  post 'create_user', to: 'pages#create_user'
  get 'chatbot', to: 'pages#chatbot'
  post 'create_response', to: 'pages#create_response'

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#intro"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: [:index, :show] do
        resources :responses, only: [:index]
      end
    end
  end
end
