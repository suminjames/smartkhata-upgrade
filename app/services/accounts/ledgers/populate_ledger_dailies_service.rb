module Accounts
  module Ledgers
    class PopulateLedgerDailiesService
      include FiscalYearModule

      def fiscal_years all_fiscal_years
        if all_fiscal_years
          fy_codes = available_fy_codes
        else
          fy_codes = [get_fy_code]
        end
        fy_codes
      end

      def patch_ledger_dailies(ledger, all_fiscal_years, branch_id)
        # need to modify this in future to accomodate current fiscal year
        fy_codes = fiscal_years all_fiscal_years

        fy_codes.each do |fy_code|
          UserSession.selected_branch_id = branch_id
          UserSession.selected_fy_code = fy_code

          ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
          ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

          # needed for entering the data balance
          # here we are migrating only single branch so need not concern about the multiple branches
          transaction_dates_org = Particular.unscoped.where(particular_status: 1, ledger_id: ledger.id).order(:transaction_date).pluck(:transaction_date).uniq

          first_daily = true
          opening_balance = 0
          LedgerDaily.unscoped.by_branch_fy_code(branch_id,fy_code).where(ledger_id: ledger.id).delete_all
          LedgerDaily.unscoped.by_fy_code_org(fy_code).where(ledger_id: ledger.id).delete_all

          transaction_dates_org.each do |date|
            balance = 0
            total_dr = 0
            total_cr = 0

            # for taking the initial ledger daily balance as opening balance
            if first_daily
              opening_balance = ledger_blnc_cost_center.opening_balance
              first_daily = false
            end

            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}') AS subquery;"
            balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            # total dr
            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 0"
            dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 1"
            cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            if (dr_amount - cr_amount - balance).abs > 0.01
              raise ArgumentError
            end

            daily_report_cost_center = LedgerDaily.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id, date: date)
            daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date)

            closing_balance = opening_balance + balance
            daily_report_cost_center.dr_amount = dr_amount
            daily_report_cost_center.cr_amount = cr_amount
            daily_report_cost_center.closing_balance = closing_balance
            daily_report_cost_center.opening_balance = opening_balance
            daily_report_cost_center.save!

            daily_report_org.dr_amount = dr_amount
            daily_report_org.cr_amount = cr_amount
            daily_report_org.closing_balance = closing_balance
            daily_report_org.opening_balance = opening_balance
            daily_report_org.save!

            # closing balance of one is opening of next
            opening_balance = closing_balance
          end
        end
      end

      def process(ledger_ids, all_fiscal_years = false, branch_id = 1)
        Ledger.where(id: ledger_ids).find_each do |ledger|
          patch_ledger_dailies(ledger,all_fiscal_years, branch_id)
        end
      end
    end
  end
end
