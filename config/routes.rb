Rails.application.routes.draw do
  resources :groups
  resources :ledgers
  resources :vouchers
  resources :particulars
  root to: 'visitors#index'
  devise_for :users
  resources :users

  namespace 'files' do
    resources :order do
      collection {post :import}
    end
    resources :floorsheet do
      collection {post :import}
    end
    resources :purchase do
      collection {post :import}
    end
  end

end
