module Accounts
  module Ledgers
    class ClosingBalanceService
      include FiscalYearModule

      def fiscal_years(all_fiscal_years, fy_code)
        fy_codes = if all_fiscal_years
                     available_fy_codes
                   elsif fy_code
                     [fy_code]
                   else
                     [get_fy_code]
                   end
        fy_codes
      end

      def patch_closing_balance(ledger, opts = {})
        all_fiscal_years = opts[:all_fiscal_years] || false
        branch_id = opts[:branch_id] || 1
        fy_code = opts[:fy_code] || get_fy_code
        current_user_id = opts[:current_user_id]

        # need to modify this in future to accomodate current fiscal year
        fy_codes = fiscal_years(all_fiscal_years, fy_code)
        set_current_user_id = ->(o) { o.current_user_id = current_user_id }
        fy_codes.each do |fy_code|
          ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, &set_current_user_id)
          ledger_blnc_cost_center = LedgerBalance.unscoped.by_branch_fy_code(branch_id, fy_code).find_or_create_by!(ledger_id: ledger.id, &set_current_user_id)
          next if ledger_blnc_org.blank?

          query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}) AS subquery;"
          balance = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

          query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}  AND transaction_type = 0"
          dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

          query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_type = 1"
          cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

          ledger_blnc_cost_center.closing_balance = balance + ledger_blnc_cost_center.opening_balance
          ledger_blnc_cost_center.dr_amount = dr_amount
          ledger_blnc_cost_center.cr_amount = cr_amount
          ledger_blnc_cost_center.opening_balance_type = ledger_blnc_cost_center.opening_balance >= 0 ? LedgerBalance.opening_balance_types[:dr] : LedgerBalance.opening_balance_types[:cr]

          query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}) AS subquery;"
          balance = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f
          query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_type = 0"
          dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

          query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND transaction_type = 1"
          cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0, 0).to_f

          ledger_blnc_org.closing_balance = balance + ledger_blnc_org.opening_balance
          ledger_blnc_org.dr_amount = dr_amount
          ledger_blnc_org.cr_amount = cr_amount
          ledger_blnc_org.opening_balance_type = ledger_blnc_org.opening_balance >= 0 ? LedgerBalance.opening_balance_types[:dr] : LedgerBalance.opening_balance_types[:cr]
          ledger_blnc_org.tap(&set_current_user_id)
          ledger_blnc_cost_center.tap(&set_current_user_id)
          ledger_blnc_cost_center.save!
          ledger_blnc_org.save!
          puts ledger.name.to_s
        end
      end

      def process(ledger_ids, current_user_id, all_fiscal_years = false, branch_id = 1, fy_code = nil)
        Ledger.where(id: ledger_ids).find_each do |ledger|
          patch_closing_balance(ledger, all_fiscal_years: all_fiscal_years, branch_id: branch_id, fy_code: fy_code, current_user_id: current_user_id)
        end
      end
    end
  end
end
