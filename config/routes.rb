# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :arrows, only: [:new, :create, :show]

  get 'dashboard', to: 'home#dashboard'

  root to: 'home#index'
end
