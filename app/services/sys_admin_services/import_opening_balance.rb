class SysAdminServices::ImportOpeningBalance  < ImportFile
  include ApplicationHelper
  # process the file
  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do

        # Delete all the ledger balance and daily activitites for the branch and the fiscal year
        LedgerBalance.by_fy_code.delete_all
        LedgerDaily.by_fy_code.delete_all

        # the selected fy code. and branch id
        fy_code = UserSession.selected_fy_code
        branch_id = UserSession.selected_branch_id


        @processed_data.each do |hash|
          # take only the data that is greater than or equal to threshold of current fiscal year
          if hash["AC_CODE"].nil? || Date.parse(hash["BALANCE_DATE"]).strftime('%Y/%m/%d').to_date < fiscal_year_first_day(fy_code)
            next
          end

          # find the client account with ac_code
          # ac_code is the primary key in mandala for client account and balance mapping
          client_account = ClientAccount.find_by(ac_code: hash["AC_CODE"])

          # skip if client account is not present
          if client_account.nil?
            next
          end

          # find or create client ledger and assign client name to the ledger
          ledger = Ledger.find_or_create_by!(client_account_id: client_account.id) do
            ledger.name = client_account.name
          end

          # the system maintains two type of balances one for all the branch and another for the particular branch
          # TODO(subas) refactor this to ledger model
          ledger_blnc_org = LedgerBalance.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
          ledger_blnc_cost_center =  LedgerBalance.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

          ledger_blnc_org.opening_balance = hash["NRS_BALANCE_AMOUNT"]
          ledger_blnc_org.closing_balance = hash["NRS_BALANCE_AMOUNT"]

          ledger_blnc_cost_center.opening_balance = hash["NRS_BALANCE_AMOUNT"]
          ledger_blnc_cost_center.closing_balance = hash["NRS_BALANCE_AMOUNT"]

          ledger_blnc_org.save!
          ledger_blnc_cost_center.save!
        end

      end
    end
  end
end