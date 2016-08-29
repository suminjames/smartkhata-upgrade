class SysAdminServices::ImportPaymentsReceipts  < ImportFile
  include ApplicationHelper

  VOUCHER_CODES = %w(PVB RCB RCP)
  # process the file
  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do
        # the selected fy code. and branch id
        fy_code = UserSession.selected_fy_code
        branch_id = UserSession.selected_branch_id

        bank_account= BankAccount.by_branch_id.first
        cash_ledger = Ledger.find_or_create_by!(name: "Cash")
        # we need the bank account to process
        import_error("No Bank account") and return if bank_account.nil?
        bank_ledger = bank_account.ledger


        @processed_data.each do |hash|
          # find the client account with ac_code
          # ac_code is the primary key in mandala for client account and balance mapping
          client_account = ClientAccount.find_by(ac_code: hash["CUSTOMER_CODE"])

          next if skip_records(hash, client_account, fy_code)

          # find or create client ledger and assign client name to the ledger
          client_ledger = Ledger.find_or_create_by!(client_account_id: client_account.id) do
            client_ledger.name = client_account.name
          end

          description = hash['REMARKS']
          _date = Date.parse(hash["ENTERED_DATE"]).strftime('%Y/%m/%d').to_date
          voucher = Voucher.create!(date: _date, date_bs: ad_to_bs_string(_date))
          voucher.desc = description
          _amount = hash['AMOUNT'].to_f

          if hash["VOUCHER_CODE"] == 'PVB'
            process_accounts(client_ledger, voucher, true, _amount, description, branch_id, @date)
            process_accounts(bank_ledger, voucher, false, _amount, description, branch_id, @date)
          elsif hash["VOUCHER_CODE"] == 'RCB'
            process_accounts(client_ledger, voucher, false, _amount, description, branch_id, @date)
            process_accounts(bank_ledger, voucher, true, _amount, description, branch_id, @date)
          else
            process_accounts(client_ledger, voucher, false, _amount, description, branch_id, @date)
            process_accounts(cash_ledger, voucher, true, _amount, description, branch_id, @date)
          end

          voucher.complete!
          voucher.save!
        end

      end
    end
  end

  def skip_records(hash, client_account, fy_code)
    if hash["CUSTOMER_CODE"].nil? ||
        Date.parse(hash["ENTERED_DATE"]).strftime('%Y/%m/%d').to_date < fiscal_year_first_day(fy_code) ||
        !VOUCHER_CODES.include?(hash["VOUCHER_CODE"]) ||
        (hash["VOID"] ? hash["VOID"].strip ==  'Y' : false) ||
        client_account.nil?
      return true
    end
    false
  end
end