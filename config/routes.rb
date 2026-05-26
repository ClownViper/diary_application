Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  get "calendar", to: "calendar#index"
  get "calendar/layer", to: "calendar#layer"
  resources :diaries
  resources :expenses
  resources :categories
  resources :health_logs do
    collection do
      get :stats
    end
  end
  resources :books
  resources :schedules
  resource :settings, only: [ :show, :update ]
  resource :content_settings, only: [ :show, :update ]

  # CSV エクスポート・インポート
  scope "csv" do
    get  "/",              to: "csv_exports#index",          as: :csv_exports
    get  "/diaries",       to: "csv_exports#diaries",        as: :csv_export_diaries
    get  "/expenses",      to: "csv_exports#expenses",       as: :csv_export_expenses
    get  "/health_logs",   to: "csv_exports#health_logs",    as: :csv_export_health_logs
    get  "/books",         to: "csv_exports#books",          as: :csv_export_books
    post "/import/diaries",      to: "csv_exports#import_diaries",      as: :csv_import_diaries
    post "/import/expenses",     to: "csv_exports#import_expenses",     as: :csv_import_expenses
    post "/import/health_logs",  to: "csv_exports#import_health_logs",  as: :csv_import_health_logs
    post "/import/books",        to: "csv_exports#import_books",        as: :csv_import_books
  end

  # Web Push通知サブスクリプション登録
  resources :push_subscriptions, only: [ :create ]

  root "dashboard#index"
end
