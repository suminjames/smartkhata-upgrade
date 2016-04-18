class Report::TrialBalanceController < ApplicationController
  def index
    @balance = Group.balance_sheet
    @balance_report = Hash.new

    @balance.each do |balance|
      @balance_report[balance.name] = balance.descendent_ledgers
    end
  end
end
