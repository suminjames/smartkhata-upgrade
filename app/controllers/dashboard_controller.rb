class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?

    # CreateMenuItemsService.new.call
    # return

    @total_users = ClientAccount.count

    @amount = 0
    @fy_code = get_fy_code



    @isin_with_largest_quantity = ShareInventory.with_most_quantity

    @purchase_bills_pending_count = Bill.purchase.find_not_settled.count

    @pending_voucher_approve_count = Voucher.pending.count

    # @custom_url_list = [
    #     {url: "asf", name: "create ledger"}
    # ]

    @identifier = get_common_name_from_dn(request.headers.env["HTTP_X_SSL_CLIENT_S_DN"])

  end

  def client_index
    authorize :dashboard, :client_index?

    # Hold information for multiple associated client accounts for current logged in user.
    @clients_info_arr = []
    client_accounts = current_user.client_accounts.order(:name)
    client_accounts.each do |client_account|
      client_account = ClientAccount.find_by_id(client_account.id)
      client_info_hash = {}
      client_info_hash[:client_account] = client_account
      client_info_hash[:pending_bills_count] = client_account.bills.pending.size
      client_info_hash[:pending_bills_path] = client_account.pending_bills_path(@selected_fy_code, @selected_branch_id)
      client_info_hash[:ledger_closing_balance] = client_account.ledger_closing_balance(@selected_fy_code, @selected_branch_id)
      client_info_hash[:grouped_share_inventories] = ShareInventory.group_by_isin_for_client(client_account.id)
      client_info_hash[:share_inventory_path] = client_account.share_inventory_path(@selected_fy_code, @selected_branch_id)
      @clients_info_arr << client_info_hash
    end
  end

end
