Rails.application.routes.draw do
  # get '/', to: '/hello/hi', via: [:get]
  # root :to => redirect('visitors#index')
  # scope "#{session[user_selected_fy_code]}/#{session[user_selected_branch_id]}" do
  # match '/' => redirect('users/sign_in'), via: [:get]
  get '/' => 'visitors#index'
  root to: 'visitors#index'
  get "cheque_entries/get_cheque_number" => "cheque_entries#get_cheque_number"
  scope "/:selected_fy_code/:selected_branch_id" do

    resources :order_request_details do
      collection do
        get :client_report
      end
      member do
        get :approve
        get :reject
      end
    end
    resources :order_requests
    namespace :master_setup do
      resources :commission_details
    end
    namespace :master_setup do
      resources :commission_infos
    end

    match "/isin_infos/combobox_ajax_filter" => "isin_infos#combobox_ajax_filter", via: [:get]
    resources :isin_infos
    namespace :master_setup do
      resources :commission_rates
    end
    namespace :master_setup do
      resources :commission_rates
      resources :broker_profiles, :except => [:destroy]
    end

    resources :broker_profiles
    resources :user_access_roles
    resources :bank_payment_letters do
      collection do
        get 'pending_letters'
        post 'finalize_payment'
      end
    end
    resources :sms_messages
    resources :menu_permissions
    resources :menu_items
    get 'general_settings/set_fy'

    get 'general_settings/set_branch'

    get 'dashboard/index'
    get 'dashboard/client_index'

    resources :nepse_chalans
    resources :vendor_accounts
    resources :employee_ledger_associations
    resources :branches, :except => [:destroy]
    resources :closeouts
    resources :share_inventories

    match "/employee_accounts/employee_access" => "employee_accounts#employee_access", via: [:get]
    match "/employee_accounts/update_employee_access" => "employee_accounts#update_employee_access", via: [:post]
    match "/employee_accounts/combobox_ajax_filter" => "employee_accounts#combobox_ajax_filter", via: [:get]

    resources :employee_accounts
    resources :banks
    resources :settlements do
      collection do
        get :show_multiple
      end
    end

    match "/cheque_entries/combobox_ajax_filter_for_beneficiary_name" => "cheque_entries#combobox_ajax_filter_for_beneficiary_name", via: [:get]

    resources :cheque_entries do
      collection do
        # get :get_cheque_number
        get :update_print_status
        get :bills_associated_with_cheque_entries
        get :settlements_associated_with_cheque_entries
        get :make_cheque_entries_unprinted
        get :bounce_show
        get :represent_show
        get :show_multiple
        get :void_show
        patch :bounce_do
        patch :void_do
        # patch :represent_do
      end
    end
    resources :bank_accounts
    resources :nepse_settlements do
      collection do
        get 'generate_bills'
      end
    end

    resources :nepse_purchase_settlements, controller: 'nepse_settlements', type: 'NepsePurchaseSettlement'
    resources :nepse_sale_settlements, controller: 'nepse_settlements', type: 'NepseSaleSettlement'

    resources :share_transactions do
      collection do
        get 'deal_cancel'
        get 'pending_deal_cancel'
        get 'capital_gain_report'
        get 'threshold_transactions'
        get 'contract_note_details'
        get 'securities_flow'
        get 'closeouts'
        get 'make_closeouts_processed'
        get 'sebo_report'
        get 'commission_report'
      end
      member do
        post 'process_closeout'
        get 'available_balancing_transactions'
      end
    end
    resources :bills do
      collection do
        get 'show_multiple'
        post 'process_selected'
        get 'sales_payment'
        post 'sales_payment_process'
        get 'select_for_settlement'
        get 'ageing_analysis'
      end
    end
    resources :transaction_messages do
      collection do
        post 'send_sms'
        post 'send_email'
        post 'sent_status'
        post 'create_multiple'
      end
    end
    resources :groups

    # scope "/:code/:branch" do
    match "/ledgers/group_members_ledgers" => "ledgers#group_members_ledgers", as: "group_member_ledgers", via: [:get]
    match "/ledgers/cashbook" => "ledgers#cashbook", via: [:get]
    match "/ledgers/daybook" => "ledgers#daybook", via: [:get]
    match "/ledgers/combobox_ajax_filter" => "ledgers#combobox_ajax_filter", via: [:get]
    match "/ledgers/merge_ledger" => "ledgers#merge_ledger", via: [:get]

    # match "/:user_selected_fy_code/:user_selected_branch_id" => "ledgers#index", via: [:get]

    resources :ledgers do
      collection do
        post 'transfer_group_member_balance'
        get 'show_all'
        get 'restricted'
      end

      member do
        get 'toggle_restriction'
      end
    end
    # end

    resources :orders, :only => [:show, :index]

    match "/vouchers/new" => "vouchers#new", :as => 'new_voucher_custom', via: [:post]
    resources :vouchers do
      collection do
        get 'pending_vouchers'
        # post 'new'
        post 'finalize_payment'
      end
    end
    resources :particulars



    match "/client_accounts/combobox_ajax_filter" => "client_accounts#combobox_ajax_filter", via: [:get]
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
      resources :cm31, only: [:new, :index] do
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
      resources :sysadmin_client_nepse_mapping, only: [:new] do
        collection do
          post :import
          get 'nepse_phone'
          get 'nepse_boid'
        end
      end
      resources :sysadmin_trial_balance, only: [:new] do
        collection {post :import}
      end

      resources :sys_admin_tasks, only: [:new] do
        collection {post :import}
      end
    end

    namespace 'reports' do
      resources :audit_trails
    end

    namespace 'report' do
      resources :balancesheet
      resources :profitandloss
      resources :trial_balance do
        collection { get :index_old}
      end
    end

    get "/test" => "test#index"

    require 'sidekiq/web'
    # TODO(sarojk): Implement sidekiq view to be only accessible by (sys)admin.
    authenticate :user do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  devise_for :users, :controllers => { :invitations => 'users/invitations' }
  resources :users, except: [:new, :create, :edit] do
    collection { get :reset_temporary_password }
  end
end



