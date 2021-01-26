class LedgerDailyJob < ActiveJob::Base
  queue_as :default
  def perform(ledger_id, current_user_id, fy_code, branch_id, accounting_dates)
    ledger = Ledger.find(ledger_id)
    accounting_dates = accounting_dates.map{|x| x.to_date }

    Accounts::Ledgers::PopulateLedgerDailiesService.new(verbose: true).patch_ledger_dailies(ledger, false, current_user_id, branch_id, fy_code, accounting_dates)
  end

  def self.perform_unique_async(ledger_id, current_user_id, fy_code, branch_id, accounting_dates)
    key = [ledger_id, current_user_id, fy_code, branch_id, accounting_dates]
    queue = Sidekiq::Queue.new('default')
    queue.each { |q| return if q.args.select{|x| x["job_class"] == "LedgerDailyJob" && x["arguments"] == key }.present? }
    self.perform_later(ledger_id, current_user_id, fy_code, branch_id, accounting_dates)
  end
end
