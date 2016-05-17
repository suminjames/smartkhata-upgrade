class Report::ProfitandlossController < ApplicationController
  def index
    @balance = Group.pnl
    @profit = Hash.new
    @profit_total = 0
    @loss_total = 0
    @loss = Hash.new
    @amount = 0
    @balance.each do |balance|
      if balance.sub_report == Group.sub_reports['Income']
        @profit[balance.name] = balance.closing_blnc
        @amount += balance.closing_blnc
        @profit_total += balance.closing_blnc
      elsif balance.sub_report == Group.sub_reports['Expense']
        @loss[balance.name] = balance.closing_blnc
        @amount += balance.closing_blnc
        @loss_total += balance.closing_blnc
      end
    end

    @loss_total -= @amount if @amount < 0
    @profit_total += @amount if @amount >0

  end
end
