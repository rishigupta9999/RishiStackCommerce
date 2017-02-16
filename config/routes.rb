Rails.application.routes.draw do
  root 'twitter#view_tweet'
  
  get 'twitter/view_tweet'
  get 'twitter/retrieve_tweets_for_handle'

  get '/auth/twitter/callback' => 'sessions#create'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
