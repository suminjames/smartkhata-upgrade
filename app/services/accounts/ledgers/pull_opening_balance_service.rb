module Accounts
  module Ledgers
    class PullOpeningBalanceService
      include FiscalYearModule
      attr_accessor :branch_id, :fy_code

      def initialize(branch_id: nil, fy_code: nil )
        @branch_id = branch_id
        @fy_code = fy_code || get_fy_code
      end

      def process(branch_id = nil)
        branch_ids = Branch.all.pluck(:id)

        if branch_id
          ledger_ids = ClientAccount.where(branch_id: branch_id).pluck(:ledger_id)
        else
          ledger_ids = Ledger.all.pluck(:id)
        end
        previous_fy_code = get_previous_fy_code fy_code
        Ledger.where(id: ledger_ids).find_each do |ledger|
          LedgerBalance.unscoped.where(fy_code: previous_fy_code).each do |ledger_balance|
            lb = LedgerBalance.unscoped.find_or_create_by!(fy_code: fy_code, ledger_id: ledger.id, branch_id: ledger_balance.branch_id)
            lb.update_attributes(opening_balance: ledger_balance.closing_balance)
          end
        end

        branch_ids.each do |branch_id|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.process(ledger_ids, false, branch_id)
        end
      end
    end
  end
end
