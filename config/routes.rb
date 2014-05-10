Maakeyolhu::Application.routes.draw do
  devise_for :admins, path: "admin", path_names: {sign_in: "login", sign_out: "logout"}

  namespace :admin do
    resources :admins,  except: [:show]
    resources :menus,   except: [:show] do
       post :page_sort, on: :collection
    end

    get "settings/homepage",       to: "settings#homepage",      as: :settings
    post "settings/homepage-save", to:  "settings#homepage_save", as: :homepage_save

    resources :pages do
       get   "sitemap",       on: :collection, as: :sitemap
       get   "clear_cache",   on: :collection, as: :clear_cache
    end
  end

  get ":permalink", to: "pages#show", as: :permalink
  root to: "pages#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
