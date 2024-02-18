FBScraper::Engine.routes.draw do
  resources :posts, path: '/listings', only: [:index, :update, :destroy] do
    collection do
      post :scrape
      delete :delete_all_unsaved
    end
  end

  resources :searches, except: [:show]

  resource :configuration, only: [:show, :update]

  match '*a', to: 'application#render_404', via: :get

  root to: "posts#index"
end
