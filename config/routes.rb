PaperClub::Application.routes.draw do
  # Sessions
  resources :sessions, only: [:create, :destroy]
  # Signin & signout
  match '/signin', to: 'sessions#create', via: :post
  match '/signout', to: 'sessions#destroy', via: :delete

  namespace :api do

    # Create a user and update user's profile
    resources :users, only: [:create, :update] 

    resources :clubs do
      # List users of the club
      # Show user info of the club
      # Remove a user from the club
      resources :users, only: [:index, :show, :destroy]

      # List/Search papers of the club
      # Upload a paper to the club
      resources :papers, only: [:index, :create]

      # List all tags of the club
      # Create an empty tag for the club
      resources :tags, only: [:index, :create]
    end

    # Show info about a paper
    # Remove a paper from its club
    # Update a paper's info
    resources :papers, only: [:show, :update, :destroy] do
      # List tags of the paper
      # Add a tag to the paper
      # Remove a tag from the paper
      resources :tags, only: [:index, :create, :destroy]

      # List notes of the paper
      # Create a note for the paper
      resources :notes, only: [:index, :create]
    end

    # Rename a tag of its club
    # Delete a tag from its club
    resources :tags, only: [:update, :destroy]

    # Show a note
    # Update a note
    # Destroy a note
    resources :notes, only: [:update, :destroy] do
      # List replies of the note
      # Create a reply for the note
      resources :replies, only: [:index, :create]
    end

    # Show a reply
    # Destroy a reply
    resources :replies, only: [:destroy]

  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
