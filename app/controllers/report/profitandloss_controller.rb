class Report::ProfitandlossController < ApplicationController
  before_action -> {authorize self}
  layout 'application_custom', only: [:index]

  def index
    drill_level = params[:drill_level].to_i if params[:drill_level].present?
    fy_code = params[:fy_code] if params[:fy_code].present?

    @selected_drill_level = drill_level || 1
    @fy_code = selected_fy_code
    @branch_id = selected_branch_id
    @balance = Group.pnl
    @profit = Hash.new
    @profit_total = 0
    @loss_total = 0
    @loss = Hash.new
    @amount = 0
    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @profit[balance.name] = balance.get_ledger_group(drill_level: @selected_drill_level, fy_code: @fy_code, branch_id: @branch_id)
        @amount += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
        @profit_total += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
      elsif balance.sub_report == Group.sub_reports['Expense']
        @loss[balance.name] = balance.get_ledger_group(drill_level: @selected_drill_level, fy_code: @fy_code, branch_id: @branch_id)
        @amount += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
        @loss_total += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
      end
    end

    @loss_total -= @amount if @amount < 0
    @profit_total += @amount if @amount >0

  end
end
