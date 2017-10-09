module Accounts
  module Ledgers
    class ClosingBalanceService
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

      def patch_closing_balance(ledger, opts={})
        all_fiscal_years = opts[:all_fiscal_years] || false
        branch_id = opts[:branch_id] || 1
        fy_code = opts[:fy_code] || get_fy_code


        # need to modify this in future to accomodate current fiscal year
        fy_codes = fiscal_years(all_fiscal_years, fy_code)

        fy_codes.each do |fy_code|
          UserSession.selected_branch_id = branch_id
          UserSession.selected_fy_code = fy_code

          ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
          ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

          if ledger_blnc_org.present?
            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}) AS subquery;"
            balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}  AND transaction_type = 0"
            dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_type = 1"
            cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f



            ledger_blnc_cost_center.closing_balance = balance + ledger_blnc_cost_center.opening_balance
            ledger_blnc_cost_center.dr_amount = dr_amount
            ledger_blnc_cost_center.cr_amount = cr_amount

            query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}) AS subquery;"
            balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_type = 0"
            dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

            query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_type = 1"
            cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
            
            ledger_blnc_org.closing_balance = balance + ledger_blnc_org.opening_balance
            ledger_blnc_org.dr_amount = dr_amount
            ledger_blnc_org.cr_amount = cr_amount

            ledger_blnc_cost_center.save!
            ledger_blnc_org.save!
            puts "#{ledger.name}"
          end
        end
      end

    end
  end
end
