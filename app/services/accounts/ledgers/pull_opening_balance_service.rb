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
        if branch_id
          ledger_ids = ClientAccount.where(branch_id: branch_id).pluck(:ledger_id)
          branch_ids == [branch_id]
        else
          ledger_ids = Ledger.all.pluck(:id)
          branch_ids = Branch.all.pluck(:id)
        end

        Ledger.where(id: ledger_ids).find_each do |ledger|

        end

        branch_ids.each do |branch_id|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.process(ledger_ids, false, branch_id)
        end

      end
    end
  end
end
