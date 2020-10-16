module Accounts
  module Ledgers
    class PopulateLedgerDailiesService
      include FiscalYearModule

      def fiscal_years all_fiscal_years, fy_code
        fy_codes = if all_fiscal_years
                     available_fy_codes
                   elsif fy_code
                     [fy_code]
                   else
                     [get_fy_code]
                   end
        fy_codes
      end

      def patch_ledger_dailies(ledger, all_fiscal_years, current_user_id, branch_id = 1, fy_code = nil, dates_affected = [])
        # need to modify this in future to accomodate current fiscal year

        fy_codes = fiscal_years(all_fiscal_years, fy_code)

        puts "Patching for #{ledger.name}"
        set_current_user_id = ->(o) { o.current_user_id = current_user_id }
        fy_codes.each do |fy_code|
          # needed for entering the data balance
          # here we are migrating only single branch so need not concern about the multiple branches

          transaction_dates_org = dates_affected
          transaction_dates_org = Particular.where(particular_status: 1, ledger_id: ledger.id, fy_code: fy_code).order(:transaction_date).pluck(:transaction_date).uniq if dates_affected.blank?

          LedgerDaily.by_branch_fy_code(branch_id, fy_code).where(ledger_id: ledger.id, date: transaction_dates_org).delete_all
          LedgerDaily.by_fy_code_org(fy_code).where(ledger_id: ledger.id, date: transaction_dates_org).delete_all

          transaction_dates_org.each do |date|
            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}') AS subquery;"
            balance = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            # total dr
            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 0"
            dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 1"
            cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            raise ArgumentError if (dr_amount - cr_amount - balance).abs > 0.01

            daily_report_cost_center = LedgerDaily.by_branch_fy_code(branch_id, fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)
            daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date, &set_current_user_id)

            daily_report_cost_center.dr_amount = dr_amount
            daily_report_cost_center.cr_amount = cr_amount
            daily_report_cost_center.current_user_id = current_user_id
            daily_report_cost_center.save!

            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_date= '#{date}') AS subquery;"
            balance_org = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            # total dr
            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}  AND transaction_date= '#{date}' AND transaction_type = 0"
            dr_amount_org = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_date= '#{date}' AND transaction_type = 1"
            cr_amount_org = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

            raise ArgumentError if (dr_amount_org - cr_amount_org - balance_org).abs > 0.01

            daily_report_org.dr_amount = dr_amount_org
            daily_report_org.cr_amount = cr_amount_org
            daily_report_org.current_user_id = current_user_id
            daily_report_org.save!
          end
        end
      end

      def process(ledger_ids, current_user_id, all_fiscal_years = false, branch_id = 1, fy_code = nil, affected_dates = [])
        Ledger.where(id: ledger_ids).find_each do |ledger|
          patch_ledger_dailies(ledger, all_fiscal_years, current_user_id, branch_id, fy_code, affected_dates)
        end
      end
    end
  end
end
