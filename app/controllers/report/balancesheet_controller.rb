class Report::BalancesheetController < ApplicationController
	def index
	  @balance = Group.balance_sheet
	  @balance_dr = Hash.new
	  @balance_cr = Hash.new
	  @opening_balance_cr = 0;
	  @opening_balance_dr = 0;
	  @opening_balance_diff = 0;

	  @balance.each do |balance|
	    if balance.sub_report == Group.sub_reports['Assets']
	      @balance_dr[balance.name] = balance.closing_blnc
	      @opening_balance_dr += balance.closing_blnc
	    end
	    if balance.sub_report == Group.sub_reports['Liabilities']
	      @balance_cr[balance.name] = balance.closing_blnc
	      @opening_balance_cr += balance.closing_blnc
	    end
	     
	    
	  end
	  @opening_balance_diff = @opening_balance_dr + @opening_balance_cr
	  
	  @opening_balance_cr -= @opening_balance_diff

	end
end
