Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :admin do
    resource :video_support_settings, only: [:edit, :update]
  end

  namespace :support do
    resources :video_tickets, only: [:index, :update, :destroy, :show], path: 'tickets/video' do
      get :history, on: :collection
      put :start, on: :member
    end
  end

  resources :video_support_request, only: [:create] do
    delete :close, on: :collection # Close active ticket
    get    :active, on: :collection # Check active ticket
  end

  get '/support', to: 'support/video_tickets#index', as: 'support_root'
end
