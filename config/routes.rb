Rails.application.routes.draw do
  get 'pages/home'
  resources :users
  get 'welcome', to: 'welcome#index'
end
