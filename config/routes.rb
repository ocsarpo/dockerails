Rails.application.routes.draw do
  resources :users
  get 'welcome', to: 'welcome#index'
end
