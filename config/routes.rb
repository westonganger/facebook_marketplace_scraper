FBScraper::Engine.routes.draw do
  resources :posts, path: '/', only: [:index, :update, :destroy] do
    collection do
      post :scrape
      delete :delete_all_unsaved
    end
  end

  resources :searches, except: [:show]

  match '*a', to: 'application#render_404', via: :get

  root to: "posts#index"
end
