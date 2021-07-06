Rails.application.routes.draw do
  root to: 'home#show'

  devise_for :users

  get 'dashboard', to: 'home#dashboard'
  
end
