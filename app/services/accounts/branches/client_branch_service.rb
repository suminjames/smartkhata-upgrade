module Accounts
  module Branches
    class ClientBranchService
      include FiscalYearModule
      include CustomDateModule


      def move_transactions(client_account, branch_id, date_bs = nil)
        ledger_ids = []
        ledger = client_account.ledger

        if date_bs
          abort unless parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          fy_codes = get_full_fy_codes_after_date(date_ad, true)
          particular_on_main_branch_count = Particular.unscoped.where(ledger_id: ledger.id).where.not(branch_id: branch_id).where('transaction_date >= ?', date_ad).count
        else
          fy_codes = [get_fy_code]
          particular_on_main_branch_count = Particular.unscoped.where(ledger_id: ledger.id).where.not(branch_id: branch_id).count
        end
        # LedgerDaily.unscoped.where(ledger_id: ledger.id).delete_all
        if particular_on_main_branch_count > 0
          if date_bs
            particulars = particulars.where('transaction_date >= ?', date_ad)
            Bill.unscoped.where(client_account_id: client_account.id).where('date >= ?', date_ad).update_all(branch_id: branch_id)
            Settlement.where(client_account_id: client_account.id).where('date >= ?', date_ad).update_all(branch_id: branch_id)
          else
            # current fiscal year only
            #get first date and where transaction date >
            first_date = fiscal_year_first_day(fy_codes[0])
            particulars = Particular.unscoped.where(ledger_id: ledger.id).where('transaction_date >= ?', first_date)
            Bill.unscoped.where(client_account_id: client_account.id).where('date >= ?', first_date).update_all(branch_id: branch_id)
            Settlement.where(client_account_id: client_account.id).where('date >= ?', first_date).update_all(branch_id: branch_id)
          end

          particulars.update_all(branch_id: branch_id)

          particulars.find_each do |particular|
            # # this case fails in case of payment voucher
            voucher = particular.voucher
            other_particulars = Particular.unscoped.where(voucher_id: voucher.id)
            other_ledger_ids =  other_particulars.pluck(:ledger_id)
            if (Ledger.where(id: other_ledger_ids).where.not(client_account_id: nil).count == 1)
              other_particulars.update_all(branch_id: branch_id)
              ledger_ids += other_ledger_ids
              voucher.update_attributes(branch_id: branch_id)
            end
          end
          ledger_ids << ledger.id
        end
        return ledger_ids, fy_codes
      end

      def patch_client_branch(client_account, branch_id, date_bs = nil )
        ActiveRecord::Base.transaction do
          ledger_ids, fy_codes = move_transactions(client_account, branch_id, date_bs)
          fy_codes.each do |fy_code|
          #   do ledger actions
            Ledger.where(id: ledger_ids).find_each do |ledger|
              # patch_ledger_dailies(ledger, false, branch_id, fy_code )
              # patch_closing_balance(ledger, false, branch_id, fy_code )
              Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, branch_id, fy_code)
              Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id, fy_code: fy_code)
            end
          end
        end
      end

      def fix_particulars_by_branch_batch(branch_id, date_bs = nil)
        ledger_ids = []
        ActiveRecord::Base.transaction do
          ClientAccount.where(branch_id: branch_id).find_each do |client_account|
            ledger = client_account.ledger
            ledger_balances = LedgerBalance.unscoped.where(ledger_id: ledger.id, branch_id: branch_id)
            opening_balance_set_for_branch = false
            ledger_balances.each { |b| (opening_balance_set_for_branch = true; break ) if b.opening_balance > 0 }
            break if opening_balance_set_for_branch

            ids, fy_codes = move_transactions(client_account, branch_id, date_bs)
            ledger_ids += ids

            fy_codes.each do |fy_code|
              #   do ledger actions
              Ledger.where(id: ledger_ids).find_each do |ledger|
                Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, branch_id, fy_code)
                Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id, fy_code: fy_code)
              end
            end
          end
        end

      end
    end
  end
end