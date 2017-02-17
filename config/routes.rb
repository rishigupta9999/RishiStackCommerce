Rails.application.routes.draw do
  root 'twitter#view_tweet'
  
  get 'twitter/view_tweet'
  get 'twitter/retrieve_tweets_for_handle'

  get '/auth/twitter/callback' => 'sessions#create'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	devise_scope :user do
	  get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
	  get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
	end

end
