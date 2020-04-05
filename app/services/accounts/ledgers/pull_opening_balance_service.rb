module Accounts
  module Ledgers
    class PullOpeningBalanceService
      include FiscalYearModule
      attr_accessor :branch_id, :fy_code, :ledger_ids, :current_user_id

      def initialize(branch_id: nil, fy_code: nil, ledger_ids: [], current_user_id: nil )
        @branch_id = branch_id
        @fy_code = fy_code || get_fy_code
        @ledger_ids = ledger_ids
        @current_user_id = current_user_id
      end

      def process
        branch_ids = Branch.all.pluck(:id)
        available_ledger_ids = ledger_ids;
        unless available_ledger_ids.size > 0
          if branch_id
            available_ledger_ids = Ledger.where(client_account_id: ClientAccount.where(branch_id: branch_id).pluck(:id)).pluck(:id)
          else
            available_ledger_ids = Ledger.all.pluck(:id)
          end
        end
        previous_fy_code = get_previous_fy_code fy_code
        pulled_ledger_ids = []
        pulled_ledger_names = []

        set_current_user_id = -> (o) { o.current_user_id = current_user_id }

        Ledger.where(id: available_ledger_ids).find_each do |ledger|
          has_closing_balance = false
          LedgerBalance.unscoped.where(fy_code: previous_fy_code, ledger_id: ledger.id).find_each do |ledger_balance|
            lb = LedgerBalance.unscoped.find_or_create_by!(fy_code: fy_code, ledger_id: ledger_balance.ledger_id, branch_id: ledger_balance.branch_id,  &set_current_user_id)
            if (lb.opening_balance !=  ledger_balance.closing_balance)
              lb.update_attributes(current_user_id: current_user_id, opening_balance: ledger_balance.closing_balance, opening_balance_type: ledger_balance.closing_balance >= 0 ? 'dr': 'cr')
              has_closing_balance = true
            end
          end

          pulled_ledger_ids << ledger.id if has_closing_balance
          pulled_ledger_names << ledger.name if has_closing_balance
        end

        puts "Populating closing balance for #{pulled_ledger_ids.size}"
        puts pulled_ledger_names.join(',') if pulled_ledger_ids.size < 50
        if pulled_ledger_ids.uniq.size > 0
          branch_ids.each do |branch_id|
            Accounts::Ledgers::PopulateLedgerDailiesService.new.process(pulled_ledger_ids.uniq, current_user_id, false, branch_id, fy_code)
            Accounts::Ledgers::ClosingBalanceService.new.process(pulled_ledger_ids.uniq, current_user_id, false, branch_id, fy_code)
          end
        end
      end
    end
  end
end
