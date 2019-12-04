module Accounts
  module Branches
    class ClientBranchService
      include FiscalYearModule
      include CustomDateModule

      def move_transactions(client_account, branch_id, date_bs, dry_run)
        ledger_ids = []
        ledger = client_account.ledger

        if date_bs
          abort unless parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          fy_codes = get_full_fy_codes_after_date(date_ad, false)
        else
          fy_codes = [get_fy_code]
          date_ad = fiscal_year_first_day(fy_codes[0])
        end
        particulars_on_other_branch_count = Particular.unscoped.where(ledger_id: ledger.id).where('transaction_date >= ?', date_ad).where.not(branch_id: branch_id).count
        # LedgerDaily.unscoped.where(ledger_id: ledger.id).delete_all
        if particulars_on_other_branch_count > 0

          bills_affected = Bill.unscoped.where(client_account_id: client_account.id).where.not(branch_id: branch_id).where('date >= ?', date_ad)
          settlements_affected = Settlement.where(client_account_id: client_account.id).where.not(branch_id: branch_id).where('date >= ?', date_ad)
          particulars_to_move = Particular.unscoped.where(ledger_id: ledger.id).where('transaction_date >= ?', date_ad).where.not(branch_id: branch_id)
          sharetransactions_affected = ShareTransaction.unscoped.where(client_account_id: client_account.id).where.not(branch_id: branch_id).where('date >= ?', date_ad)

          if dry_run
            puts "Bills affected: #{bills_affected.count}"
            puts "Settlements affected: #{settlements_affected.count}"
            puts "Particulars affected: #{particulars_on_other_branch_count}"
            puts "Sharetransactions affected: #{sharetransactions_affected.count}"
            return nil, nil
          else
            bills_affected.update_all(branch_id: branch_id)
            settlements_affected.update_all(branch_id: branch_id)
            sharetransactions_affected.update_all(branch_id: branch_id)
          end
          particulars_to_move.find_each do |particular|
            # # this case fails in case of payment voucher
            voucher = particular.voucher
            other_particulars = Particular.unscoped.where(voucher_id: voucher.id).where.not(ledger_id: ledger.id)
            other_ledger_ids =  other_particulars.pluck(:ledger_id)
            # make sure other ledgers are internal and do not affect other client accounts
            if (Ledger.where(id: other_ledger_ids).where.not(client_account_id: nil).count == 0)
              other_particulars.update_all(branch_id: branch_id)
              ledger_ids += other_ledger_ids
              voucher.update_attributes(branch_id: branch_id)
            end
          end
          particulars_to_move.update_all(branch_id: branch_id)
        else
          return nil, nil
        end
        ledger_ids << ledger.id
        return ledger_ids, fy_codes
      end


      def patch_client_branch(client_account, branch_id,  date_bs = nil, dry_run = false, current_user_id )
        ActiveRecord::Base.transaction do
          ledger_ids, fy_codes = move_transactions(client_account, branch_id, date_bs, dry_run)
          # dont patch ledger when dry run is true or ledger_ids is empty
          unless ( dry_run || ledger_ids.size == 0)
            fy_code = fy_codes[0]
            if (fy_codes.length > 1)
              # currently the fycodes are returned for all after it, need to return only the available ones
              needs_opening_balance_patch = true;
            end
            # todo after returning only availab efycodes make sure there are only two fycodes at max

            Branch.all.each do |branch|
              Ledger.where(id: ledger_ids).find_each do |ledger|
                Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, branch.id, fy_code, current_user_id: current_user_id)
                Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch.id, fy_code: fy_code, current_user_id: current_user_id)
              end
            end

            if (needs_opening_balance_patch)
              Accounts::Ledgers::PullOpeningBalanceService.new(fy_code: fy_codes[1], ledger_ids: ledger_ids).process
            end
          end
        end
      end

      def fix_particulars_by_branch_batch(branch_id, date_bs = nil, dry_run = false)
        ledger_ids = []
        ActiveRecord::Base.transaction do
          ClientAccount.where(branch_id: branch_id).find_each do |client_account|
            ledger = client_account.ledger
            ledger_balances = LedgerBalance.unscoped.where(ledger_id: ledger.id, branch_id: branch_id)
            opening_balance_set_for_branch = false
            ledger_balances.each { |b| (opening_balance_set_for_branch = true; break ) if b.opening_balance > 0 }
            break if opening_balance_set_for_branch

            ids, fy_codes = move_transactions(client_account, branch_id, date_bs, dry_run)
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
