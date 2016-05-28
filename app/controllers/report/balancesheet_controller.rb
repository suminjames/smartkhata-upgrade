class Report::BalancesheetController < ApplicationController
	def index
		drill_level = params[:drill_level].to_i if params[:drill_level].present?
    @selected_drill_level = drill_level || 1

	  @balance = Group.balance_sheet
	  @balance_dr = Hash.new
	  @balance_cr = Hash.new
	  @opening_balance_cr = 0
	  @opening_balance_dr = 0
	  @opening_balance_diff = 0

	  @balance.each do |balance|
	    if balance.sub_report == Group.sub_reports['Assets']
	      @balance_dr[balance.name] = balance.get_ledger_group(@selected_drill_level)
	      @opening_balance_dr += balance.get_ledger_group[:balance]
	    end
	    if balance.sub_report == Group.sub_reports['Liabilities']
	      @balance_cr[balance.name] = balance.get_ledger_group(@selected_drill_level)
	      @opening_balance_cr += balance.get_ledger_group[:balance]
	    end


	  end
	  @opening_balance_diff = @opening_balance_dr + @opening_balance_cr

	  @opening_balance_cr -= @opening_balance_diff

	end
end