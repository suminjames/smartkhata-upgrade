module Accounts
  module Ledgers
    class PullOpeningBalanceService
      include FiscalYearModule
      attr_accessor :branch_id, :fy_code

      def initialize(branch_id: nil, fy_code: nil )
        @branch_id = branch_id
        @fy_code = fy_code || get_fy_code
      end

      def process
        branch_ids = Branch.all.pluck(:id)
        if branch_id
          ledger_ids = Ledger.where(client_account_id: ClientAccount.where(branch_id: branch_id).pluck(:id)).pluck(:id)
        else
          ledger_ids = Ledger.all.pluck(:id)
        end
        previous_fy_code = get_previous_fy_code fy_code
        pulled_ledger_ids = []
        Ledger.where(id: ledger_ids).find_each do |ledger|
          has_closing_balance = false
          LedgerBalance.unscoped.where(fy_code: previous_fy_code, ledger_id: ledger.id).find_each do |ledger_balance|
            if ledger_balance.closing_balance != 0
              lb = LedgerBalance.unscoped.find_or_create_by!(fy_code: fy_code, ledger_id: ledger_balance.ledger_id, branch_id: ledger_balance.branch_id)
              lb.update_attributes(opening_balance: ledger_balance.closing_balance)
              has_closing_balance = true
            end
          end
          pulled_ledger_ids << ledger.id if has_closing_balance
        end

        puts "Populating closing balance for #{pulled_ledger_ids.size}"

        branch_ids.each do |branch_id|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.process(pulled_ledger_ids, false, branch_id)
        end
      end
    end
  end
end
