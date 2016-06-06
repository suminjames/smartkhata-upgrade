class DashboardController < ApplicationController
  def index
    @total_users = ClientAccount.count

    @balance = Group.pnl
    @profit_total = 0
    @loss_total = 0
    @amount = 0
    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @amount += balance.get_ledger_group[:balance]
        @profit_total += balance.get_ledger_group[:balance]
      elsif balance.sub_report == Group.sub_reports['Expense']
        @amount += balance.get_ledger_group[:balance]
        @loss_total += balance.get_ledger_group[:balance]
      end
    end

    @loss_total -= @amount if @amount < 0
    @profit_total += @amount if @amount >0

    @isin_with_largest_quantity = ShareInventory.with_most_quantity

    @purchase_bills_pending_count = Bill.purchase.find_not_settled.count

    @pending_voucher_approve_count = Voucher.pending.count

    @custom_url_list = [
        {url: "asf", name: "create ledger"}
    ]
  end
end
