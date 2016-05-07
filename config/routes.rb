Rails.application.routes.draw do
  resources :branches
  resources :closeouts
  resources :share_inventories
  resources :employee_client_associations
  resources :employee_accounts
  resources :banks
  resources :settlements
  resources :cheque_entries do
    collection {get :get_cheque_number}
  end
  resources :bank_accounts
  resources :sales_settlements do
    collection do
      get 'generate_bills'
    end
  end
  resources :share_transactions do
    collection do
      get 'deal_cancel'
    end
  end
  resources :bills do
    collection do
      get 'show_by_number'
    end
  end
  resources :groups
  resources :ledgers
  resources :vouchers do
    collection do
      post 'finalize_payment'
    end
  end
  resources :particulars
  root to: 'visitors#index'
  devise_for :users
  resources :users, except: [:new, :create, :edit]
  resources :client_accounts

  namespace 'files' do
    resources :orders, only: [:new, :index] do
      collection {post :import}
    end
    resources :floorsheets, only: [:new, :index] do
      collection {post :import}
    end
    resources :sales, only: [:new, :index] do
      collection {post :import}
    end
    resources :dpa5 do
      collection {post :import}
    end
    resources :calendars, only: [:new] do
      collection {post :import}
    end
    resources :closeouts, only: [:new] do
      collection {post :import}
    end
  end

  namespace 'report' do
    resources :balancesheet
    resources :profitandloss
    resources :trial_balance
  end


end
