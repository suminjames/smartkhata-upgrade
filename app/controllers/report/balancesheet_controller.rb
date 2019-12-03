class Report::BalancesheetController < ApplicationController
  before_action -> {authorize self}
  layout 'application_custom', only: [:index]

  def index
    drill_level = params[:drill_level].to_i if params[:drill_level].present?
    fy_code = params[:fy_code] if params[:fy_code].present?
    branch_id = params[:branch_id] if params[:branch_id].present?

    @selected_drill_level = drill_level || 1
    @fy_code = selected_fy_code
    @branch_id = selected_branch_id
    @balance = Group.balance_sheet
    @balance_dr = Hash.new
    @balance_cr = Hash.new
    @opening_balance_cr = 0
    @opening_balance_dr = 0
    @opening_balance_diff = 0

    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Assets']
        @balance_dr[balance.name] = balance.get_ledger_group(drill_level: @selected_drill_level, fy_code: @fy_code, branch_id: @branch_id)
        @opening_balance_dr += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
      end
      if balance.sub_report == Group.sub_reports['Liabilities']
        @balance_cr[balance.name] = balance.get_ledger_group(drill_level: @selected_drill_level, fy_code: @fy_code, branch_id: @branch_id)
        @opening_balance_cr += balance.get_ledger_group(fy_code: @fy_code, branch_id: @branch_id)[:balance]
      end


    end
    @opening_balance_diff = @opening_balance_dr + @opening_balance_cr

    @opening_balance_cr -= @opening_balance_diff
  end
end