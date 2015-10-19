GraphStarter::Engine.routes.draw do
  resources :groups
  root 'assets#home'

  resources :categories
  resources :groups do
    member do
      get :users_to_add
    end
  end

  get 'models' => 'models#index', as: :models
  get 'models/:name' => 'models#show', as: :model

  get 'authorizables/user_and_group_search.json' => 'authorizables#user_and_group_search'
  get 'authorizables/:model_slug/:id.:format' => 'authorizables#show'
  put 'authorizables/:model_slug/:id.:format' => 'authorizables#update'

  get ':model_slug' => 'assets#index', as: :assets
  get ':model_slug/:id' => 'assets#show', as: :asset
  get ':model_slug/:id/edit' => 'assets#edit', as: :edit_asset
  get ':model_slug/search/:query.json' => 'assets#search', as: :search_assets
  patch ':model_slug/:id' => 'assets#update'  
end
