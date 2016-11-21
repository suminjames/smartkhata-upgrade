class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?

    # CreateMenuItemsService.new.call
    # return

    @total_users = ClientAccount.count

    @balance = Group.pnl
    @profit_total = 0
    @loss_total = 0
    @amount = 0
    @fy_code = get_fy_code

    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @amount += balance.get_ledger_group(fy_code: @fy_code)[:balance]
        @profit_total += balance.get_ledger_group(fy_code: @fy_code)[:balance]
      elsif balance.sub_report == Group.sub_reports['Expense']
        @amount += balance.get_ledger_group(fy_code: @fy_code)[:balance]
        @loss_total += balance.get_ledger_group(fy_code: @fy_code)[:balance]
      end
    end

    @loss_total -= @amount if @amount < 0
    @profit_total += @amount if @amount >0

    @isin_with_largest_quantity = ShareInventory.with_most_quantity

    @purchase_bills_pending_count = Bill.purchase.find_not_settled.count

    @pending_voucher_approve_count = Voucher.pending.count

    # @custom_url_list = [
    #     {url: "asf", name: "create ledger"}
    # ]

    @info = request.env["HTTP_X_SSL_CLIENT_S_DN"];
    @verify = request.env["HTTP-X-CLIENT-VERIFY"];
  end

  def client_index
    authorize :dashboard, :index?
    # Hold information for multiple associated client accounts for current logged in user.
    @clients_info_arr = []
    client_accounts = current_user.client_accounts.order(:name)
    client_accounts.each do |client_account|
      client_account = ClientAccount.find_by_id(client_account.id)
      client_info_hash = {}
      client_info_hash[:client_account] = client_account
      client_info_hash[:pending_bills_count] = client_account.bills.pending.size
      client_info_hash[:pending_bills_path] = client_account.pending_bills_path
      client_info_hash[:ledger_closing_balance] = client_account.ledger_closing_balance
      client_info_hash[:grouped_share_inventories] = ShareInventory.group_by_isin_for_client(client_account.id)
      client_info_hash[:share_inventory_path] = client_account.share_inventory_path
      @clients_info_arr << client_info_hash
    end
  end

end
