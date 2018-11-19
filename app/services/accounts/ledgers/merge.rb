module Accounts
  module Ledgers
    class Merge < BaseService
      include FiscalYearModule
      attr_reader :ledger_to_merge_to, :ledger_to_merge_from
      def initialize(merge_to, merge_from)
        @ledger_to_merge_to = Ledger.find(merge_to)
        @ledger_to_merge_from = Ledger.find(merge_from)
      end

      def call
        res = false
        ActiveRecord::Base.transaction do

          fix_opening_balances
          fix_ledger_dailies_and_closing_balances
          merge_client_accounts
          ledger_to_merge_from.delete
          ledger_to_merge_to.client_code = ledger_to_merge_to.client_code.to_s.squish
          ledger_to_merge_to.name = ledger_to_merge_to.name.to_s.squish
          ledger_to_merge_to.save!

          mandala_mapping_for_deleted_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_from).first
          mandala_mapping_for_remaining_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_to).first

          if mandala_mapping_for_deleted_ledger.present? && mandala_mapping_for_remaining_ledger.present?
          #   do nothing
          elsif mandala_mapping_for_deleted_ledger.present?
            mandala_mapping_for_deleted_ledger.ledger_id = ledger_to_merge_to
            mandala_mapping_for_deleted_ledger.save!
          end
          res = true
        end
        return res
      end

      def fix_ledger_dailies_and_closing_balances
        particulars_to_be_moved = Particular.unscoped.where(ledger_id: ledger_to_merge_from.id)
        branches = particulars_to_be_moved.pluck(:branch_id).uniq
        # change the ledger id to new one and delete balance and ledger dailies
        particulars_to_be_moved.update_all(ledger_id: ledger_to_merge_to.id)
        branches.each do |branch_id|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger_to_merge_to, true, branch_id)
          Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger_to_merge_to, all_fiscal_years: true, branch_id: branch_id)
        end

        LedgerBalance.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all
        LedgerDaily.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all
      end

      def fix_opening_balances
        available_fy_codes.each do |fy_code|
          Branch.all.pluck(:id).push(nil).each_with_index do |branch_id, index|
            ledger_balance = LedgerBalance.unscoped.where(branch_id: branch_id, ledger_id: ledger_to_merge_to.id, fy_code: fy_code).first
            ledger_balance_other = LedgerBalance.unscoped.where(branch_id: branch_id, ledger_id: ledger_to_merge_from.id, fy_code: fy_code).first

            if ledger_balance && ledger_balance_other
              ledger_balance.opening_balance  += ledger_balance_other.opening_balance
              ledger_balance.opening_balance_type = ledger_balance.opening_balance >= 0 ? 'dr': 'cr'
              ledger_balance.save!
            end
          end
        end
      end

      # delete client accounts too
      def merge_client_accounts
        client_account_to_persist = ledger_to_merge_to.client_account
        client_account_to_delete = ledger_to_merge_from.client_account
        if client_account_to_delete
          if client_account_to_persist && client_account_to_persist != client_account_to_delete
            # for blank nepse codes take nepse code from the deleted ones
            if client_account_to_persist.nepse_code.blank?
              nepse_code = client_account_to_delete.nepse_code
              client_account_to_persist.nepse_code = nepse_code
              ledger_to_merge_to.client_code = nepse_code
            end

            client_account_to_persist.mobile_number ||= client_account_to_delete.mobile_number
            client_account_to_persist.email ||= client_account_to_delete.email
            client_account_to_persist.skip_validation_for_system = true

            TransactionMessage.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
            ShareTransaction.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
            Bill.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
            Settlement.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
            ChequeEntry.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
            Order.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)

            client_account_to_delete.delete

            client_account_to_persist.name = client_account_to_persist.name.squish
            client_account_to_persist.nepse_code = client_account_to_persist.nepse_code.squish
            client_account_to_persist.save!
          else
            ledger_to_merge_to.client_account = client_account_to_delete
            ledger_to_merge_to.client_code = client_account_to_delete.nepse_code.squish
          end
        end
        ledger_to_merge_to
      end
    end
  end
end
