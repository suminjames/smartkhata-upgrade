Rails.application.routes.draw do
  resources :share_transactions
  resources :bills
  resources :groups
  resources :ledgers
  resources :vouchers
  resources :particulars
  root to: 'visitors#index'
  devise_for :users
  resources :users

  namespace 'files' do
    resources :orders do
      collection {post :import}
    end
    resources :floorsheets do
      collection {post :import}
    end
    resources :sales do
      collection {post :import}
    end
  end

  namespace 'report' do
    resources :balancesheet
    resources :profitandloss
  end


end
