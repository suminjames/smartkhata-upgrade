Rails.application.routes.draw do
  resources :receipts
  resources :cheque_entries
  resources :bank_accounts
  resources :sales_settlements do
    collection do
      get 'generate_bills'
    end
  end
  resources :share_transactions
  resources :bills
  resources :groups
  resources :ledgers
  resources :vouchers
  resources :particulars
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :client_accounts
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
    resources :dpa5 do
      collection {post :import}
    end
  end

  namespace 'report' do
    resources :balancesheet
    resources :profitandloss
  end


end
