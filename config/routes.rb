# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  get 'dashboard', to: 'home#dashboard'

  root to: 'home#show'
end
