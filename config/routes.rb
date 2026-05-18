Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  get "calendar", to: "calendar#index"
  get "calendar/layer", to: "calendar#layer"
  resources :diaries
  resources :expenses
  resources :categories

  root "dashboard#index"
end
