class Report::ProfitandlossController < ApplicationController
  def index
    drill_level = params[:drill_level].to_i if params[:drill_level].present?
    @selected_drill_level = drill_level || 1

    @balance = Group.pnl
    @profit = Hash.new
    @profit_total = 0
    @loss_total = 0
    @loss = Hash.new
    @amount = 0
    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @profit[balance.name] = balance.get_ledger_group(@selected_drill_level)
        @amount += balance.get_ledger_group[:balance]
        @profit_total += balance.get_ledger_group[:balance]
      elsif balance.sub_report == Group.sub_reports['Expense']
        @loss[balance.name] = balance.get_ledger_group(@selected_drill_level)
        @amount += balance.get_ledger_group[:balance]
        @loss_total += balance.get_ledger_group[:balance]
      end
    end

    @loss_total -= @amount if @amount < 0
    @profit_total += @amount if @amount >0

  end
end
