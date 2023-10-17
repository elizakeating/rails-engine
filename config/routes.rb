Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        get "/items", to: "merchant_items#index"
      end

      resources :items do
        get "/merchant", to: "merchant_items#show"
      end
    end
  end
end
