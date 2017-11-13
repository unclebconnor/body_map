Rails.application.routes.draw do
  
  get 'annotation/index'

  get 'annotation/new'

  get 'annotation/edit'

  get 'map/index'

  get 'map/show'

  get 'map/new'

  get 'map/edit'

  get 'user/show'

  get 'user/edit'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :annotation
  resources :map
  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]

  root to: "home#show"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
