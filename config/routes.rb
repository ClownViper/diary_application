Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  get "calendar", to: "calendar#index"
  get "calendar/layer", to: "calendar#layer"
  resources :diaries
  resources :expenses
  resources :categories
  resources :health_logs
  resources :books
  resources :schedules
  resource :settings, only: [ :show, :update ]
  resource :content_settings, only: [ :show, :update ]

  # Web Push通知サブスクリプション登録
  resources :push_subscriptions, only: [ :create ]

  root "dashboard#index"
end
