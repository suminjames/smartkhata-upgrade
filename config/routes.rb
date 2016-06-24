Rails.application.routes.draw do
  get 'general_settings/set_fy'

  get 'general_settings/set_branch'

  resources :transaction_messages
  get 'dashboard/index'

  resources :nepse_chalans
  resources :vendor_accounts
  resources :employee_ledger_associations
  resources :branches
  resources :closeouts
  resources :share_inventories
  resources :employee_client_associations
  resources :employee_accounts
  resources :banks
  resources :settlements do
    collection do
      get :show_multiple
    end
  end
  resources :cheque_entries do
    collection do
      get :get_cheque_number
      get :update_print
      get :bounce
      get :represent
    end

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
      get 'pending_deal_cancel'
    end
  end
  resources :bills do
    collection do
      get 'show_by_number'
      get 'print'
      post 'process_selected'
    end
  end
  resources :groups

  match "/ledgers/group_members_ledgers" => "ledgers#group_members_ledgers", as: "group_member_ledgers", via: [:get]

  resources :ledgers do
    collection do
      post 'transfer_group_member_balance'
    end
  end
  resources :orders
  match "/vouchers/new" => "vouchers#new", :as => 'new_voucher_custom', via: [:post]
  resources :vouchers do
    collection do
      get 'pending_vouchers'
      # post 'new'
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
    resources :sysadmin_uploads, only: [:new] do
      collection {post :import}
    end
    resources :sysadmin_trial_balance, only: [:new] do
      collection {post :import}
    end
  end

  namespace 'report' do
    resources :balancesheet
    resources :profitandloss
    resources :trial_balance
    resources :threshold_transactions
  end

  get "/test" => "test#index"


end
