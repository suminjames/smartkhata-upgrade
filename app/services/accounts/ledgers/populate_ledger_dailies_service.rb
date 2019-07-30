module Accounts
  module Ledgers
    class PopulateLedgerDailiesService
      include FiscalYearModule

      def fiscal_years all_fiscal_years, fy_code
        if all_fiscal_years
          fy_codes = available_fy_codes
        elsif fy_code
          fy_codes = [fy_code]
        else
          fy_codes = [get_fy_code]
        end
        fy_codes
      end

      def patch_ledger_dailies(ledger, all_fiscal_years, branch_id = 1, fy_code = nil, current_user_id)
        # need to modify this in future to accomodate current fiscal year
        fy_codes = fiscal_years(all_fiscal_years, fy_code)

        puts "Patching for #{ledger.name}"
        set_current_user_id = -> (o) { o.current_user_id = current_user_id }
        fy_codes.each do |fy_code|
          # UserSession.selected_branch_id = branch_id
          # UserSession.selected_fy_code = fy_code

          ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, &set_current_user_id)
          ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(branch_id, fy_code).find_or_create_by!(ledger_id: ledger.id, &set_current_user_id)

          # needed for entering the data balance
          # here we are migrating only single branch so need not concern about the multiple branches
          transaction_dates_org = Particular.unscoped.where(particular_status: 1, ledger_id: ledger.id, fy_code: fy_code).order(:transaction_date).pluck(:transaction_date).uniq

          first_daily = true
          opening_balance = 0
          opening_balance_org = 0
          LedgerDaily.by_branch_fy_code(branch_id,fy_code).where(ledger_id: ledger.id).delete_all
          LedgerDaily.by_fy_code_org(fy_code).where(ledger_id: ledger.id).delete_all

          transaction_dates_org.each do |date|
            balance = 0
            total_dr = 0
            total_cr = 0

            # for taking the initial ledger daily balance as opening balance
            if first_daily
              opening_balance = ledger_blnc_cost_center.opening_balance
              opening_balance_org = ledger_blnc_org.opening_balance
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

            daily_report_cost_center = LedgerDaily.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)
            daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

            closing_balance = opening_balance + balance
            daily_report_cost_center.dr_amount = dr_amount
            daily_report_cost_center.cr_amount = cr_amount
            daily_report_cost_center.closing_balance = closing_balance
            daily_report_cost_center.opening_balance = opening_balance
            daily_report_cost_center.current_user_id = current_user_id
            daily_report_cost_center.save!

            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_date= '#{date}') AS subquery;"
            balance_org = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            # total dr
            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}  AND transaction_date= '#{date}' AND transaction_type = 0"
            dr_amount_org = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_date= '#{date}' AND transaction_type = 1"
            cr_amount_org = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            if (dr_amount_org - cr_amount_org - balance_org).abs > 0.01
              raise ArgumentError
            end
            closing_balance_org = opening_balance_org + balance_org
            daily_report_org.dr_amount = dr_amount_org
            daily_report_org.cr_amount = cr_amount_org
            daily_report_org.closing_balance = closing_balance_org
            daily_report_org.opening_balance = opening_balance_org
            daily_report_org.current_user_id = current_user_id
            daily_report_org.save!

            # closing balance of one is opening of next
            opening_balance = closing_balance
            opening_balance_org =  closing_balance_org
          end
        end
      end


      def process(ledger_ids, all_fiscal_years = false, branch_id = 1, fy_code = nil, current_user_id)
        Ledger.where(id: ledger_ids).find_each do |ledger|
          patch_ledger_dailies(ledger,all_fiscal_years, branch_id, fy_code, current_user_id)
        end
      end
    end
  end
end
