  class FilesImportServices::ImportFloorsheet  < ImportFile
    attr_reader :date, :error_type, :new_client_accounts

    include CommissionModule
    include ShareInventoryModule
    include ApplicationHelper

    FILETYPE = FileUpload::file_types[:floorsheet]
    @@transaction_type_buying = ShareTransaction.transaction_types['buying']
    @@transaction_type_selling =  ShareTransaction.transaction_types['selling']

    def initialize(file, is_partial_upload = false)
      @date = nil
      @is_partial_upload = is_partial_upload
      super(file)
    end


    def process
      if @is_partial_upload
        process_full_partial(@is_partial_upload)
      else
        process_full_partial(@is_partial_upload)
      end
    end

    def process_full_partial(is_partial)
      # read the xls file
      xlsx = Roo::Spreadsheet.open(@file, extension: :xls)

      # hash to store unique combination of isin, transaction type (buying/selling), client
      hash_dp_count = Hash.new 0
      hash_dp = Hash.new

      # array to store processed data
      @processed_data = []
      @raw_data = []

      import_error("Please verify and Upload a valid file") and return if (is_invalid_file_data(xlsx))
      # grab date from the first record
      date_data = xlsx.sheet(0).row(5)[4][/\((.+)\)/, 1].strip

      # convert a string to date
      @date = Date.parse("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")

      import_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if (@date.nil? || (!parsable_date? @date))

      # fiscal year and date should match
      # file_error("Please change the fiscal year.") and return unless date_valid_for_fy_code(@date)
      unless date_valid_for_fy_code(@date)
        import_error("Please change the fiscal year.") and return
      end

      if !is_partial
        # do not reprocess file if it is already uploaded
        floorsheet_file = FileUpload.find_by(file_type: FILETYPE, report_date: @date)
        # raise soft error and return if the file is already uploaded
        import_error("The file is already uploaded") and return unless floorsheet_file.nil?
      end
      settlement_date = Calendar::t_plus_3_trading_days(@date)
      fy_code = get_fy_code(@date)

      # get bill number once and increment it on rails code
      # dont do database query for each creation
      @bill_number = get_bill_number(fy_code)

      # loop through 13th row to last row
      # parse the data
      new_client_accounts = []
      data_sheet = xlsx.sheet(0)

      (7..(data_sheet.last_row)).each do |i|
        row_data = data_sheet.row(i)
        relevant_data = relevant_data_from_row(row_data)
        data_hash = relevant_data_hash(relevant_data)

        contract_no = data_hash[:contract_no]

        break if contract_no.blank?

        import_error("File contains invalid data") and return if is_relevant_data_invalid?(data_hash)

        if is_partial
          # If share transaction already in db, skip it!
          if ShareTransaction.find_by_contract_no(contract_no).present?
            next
          end
        end

        @raw_data << relevant_data

        company_symbol, client_name, client_nepse_code, bank_deposit = selected_columns_from_data_hash(data_hash, %i[company_symbol client_name client_nepse_code bank_deposit])

        client_nepse_code = client_nepse_code.upcase

        # check for the bank deposit value which is available only for buying
        # store the count of transaction for unique client,company, and type of transaction
        transaction_type = bank_deposit.blank? ? :selling : :buying

        if !is_partial
          hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] += 1
          # Maintain list of new client accounts not in the system yet.
          unless ClientAccount.unscoped.find_by(nepse_code: client_nepse_code)
            # add  new client if not present hash
            add_client_account(client_name, client_nepse_code,new_client_accounts)
          end
        end

        if is_partial
          client = ClientAccount.unscoped.find_by(nepse_code: client_nepse_code)
          if client.present?
            if hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s + '_counted_from_db'] == 0
              # add hash_dp_count new key value
              hash_dp_count_increment(transaction_type,client,company_symbol,client_nepse_code,hash_dp_count)
            end
            hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] += 1
          else
            # Maintain list of new client accounts not in the system yet.
            add_client_account(client_name,client_nepse_code, new_client_accounts)
          end
        end
      end

      # Client information should be available before file upload.
      unless new_client_accounts.blank?
        @error_type = 'new_client_accounts_present'
        @new_client_accounts = new_client_accounts
        import_error(new_client_accounts_error_message(new_client_accounts)) and return
      end

      commission_info = get_commission_info_with_detail(@date)

      # critical functionality happens here
      ActiveRecord::Base.transaction do
          @raw_data.each do |arr|
          @processed_data << process_record_for_full_upload(arr, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
        end
        FileUpload.find_or_create_by!(file_type: FILETYPE, report_date: @date)
      end
    end

    def relevant_data_from_row(row_data)
      # rawdata =[
      # 	Contract No.,
      # 	Symbol,
      # 	Buyer Broking Firm Code,
      # 	Seller Broking Firm Code,
      # 	Client Name,
      # 	Client Code,
      # 	Quantity,
      # 	Rate,
      # 	Amount,
      # 	Stock Comm.,
      # 	Bank Deposit,
      # ]
      [row_data[1], row_data[3], row_data[7], row_data[8], row_data[10], row_data[11], row_data[12], row_data[14], row_data[17], row_data[20], row_data[23]]
    end

    # hash from array of relevant data
    def relevant_data_hash(data)
      keys = %i[contract_no company_symbol buyer seller client_name client_nepse_code quantity rate amount commission bank_deposit]
      keys.zip(data).to_h
    end

    # returns array
    def selected_columns_from_data_hash(data_hash, keys)
      data_hash.slice(*keys).values
    end

    def is_relevant_data_invalid? data_hash
      required_data_array = data_hash.except(:bank_deposit).values
      required_data_array.select{|x| x.blank? }.present? ||
        data_hash[:amount] != data_hash[:rate] * data_hash[:quantity]
    end


    def add_client_account(client_name,client_nepse_code,new_client_accounts)
      client_account_hash = {client_name: client_name, client_nepse_code: client_nepse_code}
      unless new_client_accounts.include?(client_account_hash)
        new_client_accounts << client_account_hash
      end
    end

    def hash_dp_count_increment(transaction_type,client,company_symbol,client_nepse_code,hash_dp_count)
      company_info = IsinInfo.find_or_create_new_by_symbol(company_symbol)

      relevant_share_transactions_count = relevant_share_transactions_count(@date,client.id,company_info.id, ShareTransaction.transaction_types[transaction_type] )

      hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] = relevant_share_transactions_count
      # Switch the flag `**_counted_from_db` to true
      hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s + '_counted_from_db'] = 1
    end

    # TODO: Change arr to hash (maybe)
    # arr =[
    # 	Contract No.,
    # 	Symbol,
    # 	Buyer Broking Firm Code,
    # 	Seller Broking Firm Code,
    # 	Client Name,
    # 	Client Code,
    # 	Quantity,
    # 	Rate,
    # 	Amount,
    # 	Stock Comm.,
    # 	Bank Deposit,
    # ]
    # hash_dp => custom hash to store unique isin , buying/selling, customer per day
    def process_record_for_full_upload(arr, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
      # debugger
      contract_no = arr[0].to_i
      company_symbol = arr[1]
      buyer_broking_firm_code = arr[2]
      seller_broking_firm_code = arr[3]
      client_name = arr[4]
      client_nepse_code = arr[5].upcase
      share_quantity = arr[6].to_i
      share_rate = arr[7]
      share_net_amount = arr[8]
      #TODO look into the usage of arr[9] (Stock Commission)
      # commission = arr[9]
      bank_deposit = arr[10]
      # arr[11] = NIL
      is_purchase = false

      dp = 0
      bill = nil
      type_of_transaction = @@transaction_type_buying

      client = ClientAccount.unscoped.find_by!(nepse_code: client_nepse_code)

      # client branch id is used to enforce branch cost center
      client_branch_id = client.branch_id
      # check for the bank deposit value which is available only for buying
      # used 25.0 instead of 25 to get number with decimal
      # hash_dp_count is used for the dp charges
      # hash_dp is used to group transactions into bill
      # bill contains all the transactions done for a user for each type( purchase / sales)
      if bank_deposit.blank?
        dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'selling']
        type_of_transaction = @@transaction_type_selling
      else
        is_purchase = true
        # create or find a bill by the number
        dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'buying']
        # group all the share transactions for a client for the day
        if hash_dp.key?(client_nepse_code+'buying')
          bill = find_or_create_bill(hash_dp[client_nepse_code+'buying'],fy_code,@date,client.id)
        else
          hash_dp[client_nepse_code+'buying'] = @bill_number
          bill = find_or_create_bill(@bill_number,fy_code,@date,client.id) do |b|
            b.bill_type = Bill.bill_types['purchase']
            b.client_name = client_name
            b.branch_id = client_branch_id
          end
          @bill_number += 1
        end
      end

      # amount: amount of the transaction
      # commission: Broker commission
      # nepse: nepse commission
      # tds: tds amount deducted from the broker commission
      # sebon: sebon fee
      # bank_deposit: deposit to nepse
      cgt = 0
      amount = share_net_amount

      commission = get_commission(amount, commission_info)
      commission_rate = get_commission_rate(amount, commission_info)

      # redundant for now
      # compliance_fee = compliance_fee(commission, @date)
      # commission for broker for the transaction
      broker_purchase_commission = broker_commission(commission, commission_info)
      nepse = nepse_commission_amount(commission, commission_info)

      tds = broker_purchase_commission * 0.15

      # # since compliance fee is debit from broker purchase commission
      # # reduce amount of the purchase commission in the system.
      # purchase_commission = broker_purchase_commission - compliance_fee
      sebon = amount * 0.00015
      bank_deposit = nepse + tds + sebon + amount

      # amount to be debited to client account
      # @client_dr = nepse + sebon + amount + broker_purchase_commission + dp
      @client_dr = (bank_deposit + broker_purchase_commission - tds + dp) if bank_deposit.present?

      # get company information to store in the share transaction
      company_info = IsinInfo.find_or_create_new_by_symbol(company_symbol)
      # TODO: Include base price

      transaction = ShareTransaction.create(
          contract_no: contract_no,
          isin_info_id: company_info.id,
          buyer: buyer_broking_firm_code,
          seller: seller_broking_firm_code,
          raw_quantity: share_quantity,
          quantity: share_quantity,
          share_rate: share_rate,
          share_amount: share_net_amount,
          sebo: sebon,
          commission_rate: commission_rate,
          commission_amount: commission,
          dp_fee: dp,
          cgt: cgt,
          net_amount: @client_dr, #calculated as @client_dr = nepse + sebon + amount + purchase_commission + dp. Not to be confused with share_amount
          bank_deposit: bank_deposit,
          transaction_type: type_of_transaction,
          date: @date,
          client_account_id: client.id,
          tds: tds,
          nepse_commission: nepse,
          branch_id: client_branch_id
      )
      # debugger
      # TODO(sarojk): Find a way to fix for pre-uploaded(or pre-processed) share transactions.
      update_share_inventory(client.id, company_info.id, transaction.quantity, transaction.buying?)

      bill_id = nil
      bill_number = nil
      full_bill_number = nil

      if type_of_transaction == @@transaction_type_buying
        bill.share_transactions << transaction
        bill.net_amount += transaction.net_amount
        bill.balance_to_pay = bill.net_amount
        bill.settlement_date = settlement_date
        bill.save!
        bill_id = bill.id
        full_bill_number = "#{fy_code}-#{bill.bill_number}"

        client_group = Group.find_or_create_by!(name: "Clients")
        # create client ledger if not exist
        client_ledger = Ledger.find_or_create_by!(client_code: client_nepse_code) do |ledger|
          ledger.name = client_name
          ledger.client_account_id = client.id
          ledger.group_id = client_group.id
        end

        # find or create predefined ledgers
        purchase_commission_ledger =find_or_create_ledger_by_name("Purchase Commission")
        nepse_ledger = find_or_create_ledger_by_name("Nepse Purchase")
        tds_ledger = find_or_create_ledger_by_name("TDS")
        dp_ledger = find_or_create_ledger_by_name("DP Fee/ Transfer")
        compliance_ledger = find_or_create_ledger_by_name( "Compliance Fee")


        # update description
        description = "Shares purchased (#{share_quantity}*#{company_symbol}@#{share_rate}) for #{client_name}"
        # update ledgers value
        # voucher date will be today's date
        # bill date will be earlier

        voucher = Voucher.create!(date: @date, date_bs: ad_to_bs_string(@date))
        voucher.bills_on_creation << bill
        voucher.share_transactions << transaction
        voucher.desc = description
        voucher.complete!
        voucher.save!

        #TODO replace bill from particulars with bill from voucher
        process_accounts(client_ledger, voucher, true, @client_dr, description, client_branch_id, @date)
        # process_accounts(compliance_ledger, voucher, false, compliance_fee, description,client_branch_id, @date) if compliance_fee > 0
        process_accounts(tds_ledger, voucher, true, tds, description, client_branch_id, @date)
        process_accounts(purchase_commission_ledger, voucher, false, broker_purchase_commission, description, client_branch_id, @date)
        process_accounts(dp_ledger, voucher, false, dp, description, client_branch_id, @date) if dp > 0
        process_accounts(nepse_ledger, voucher, false, bank_deposit, description, client_branch_id, @date)
      end


      arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
    end



    def repatch_share_transactions_accomodating_partial_upload(processed_share_transactions_for_the_date)
      processed_share_transactions_for_the_date.each do |share_transaction|

        # Patch dp fee in share transaction (but not quite yet on voucher)

        relevant_share_transactions_count =  relevant_share_transactions_count(share_transaction.date,share_transaction.client_account.id,
          share_transaction.isin_info.id,ShareTransaction.transaction_types[share_transaction.transaction_type])

        stale_dp_fee_for_st = share_transaction.dp_fee
        updated_dp_fee_for_st = 25.0 / relevant_share_transactions_count
        difference_of_dp_fee_for_st = stale_dp_fee_for_st - updated_dp_fee_for_st
        share_transaction.dp_fee =  updated_dp_fee_for_st
        share_transaction.save!

        # Readjustment of dp fee in vouchers, and other voucher related necessary adjustment only required for purchase transactions.
        # If no changes in (apparently) stale and new dp_fee, no further changes needed.
        if share_transaction.buying? && difference_of_dp_fee_for_st.abs > 0.1
          # Readjust share_transaction's net_amount
          client_dr = share_transaction.net_amount - stale_dp_fee_for_st + share_transaction.dp_fee
          share_transaction.net_amount = client_dr
          share_transaction.save!

          # Readjust dp fee in vouchers
          description = "Reverse entry to accomodate dp fee for transaction number #{share_transaction.contract_no} due to partial uploads for #{ad_to_bs(@date)}."
          date = share_transaction.date
          new_voucher = Voucher.create!(date: date, date_bs: ad_to_bs_string(date), desc: description)



          client_ledger = share_transaction.client_account.ledger
          process_accounts(client_ledger, new_voucher, false, difference_of_dp_fee_for_st, description, share_transaction.client_account.branch_id, @date)

          # Re-process the (dp_fee updated) share transaction
          dp_ledger = find_or_create_ledger_by_name( "DP Fee/ Transfer")
          process_accounts(dp_ledger, new_voucher, true,  difference_of_dp_fee_for_st, description, share_transaction.client_account.branch_id, @date)

          # Re-adjusting of  bill not needed, as dp fee for a bill is calculated through its share transactions (on the fly).
        end

      end
    end

    def relevant_share_transactions_count(date, client_account_id,isin_info_id,transaction_type)
      ShareTransaction.where(
          date: date,
          client_account_id:client_account_id,
          isin_info_id: isin_info_id,
          transaction_type: transaction_type
      ).size
    end
    # TODO: Change arr to hash (maybe)
    # arr =[
    # 	Contract No.,
    # 	Symbol,
    # 	Buyer Broking Firm Code,
    # 	Seller Broking Firm Code,
    # 	Client Name,
    # 	Client Code,
    # 	Quantity,
    # 	Rate,
    # 	Amount,
    # 	Stock Comm.,
    # 	Bank Deposit,
    # ]
    # hash_dp => custom hash to store unique isin , buying/selling, customer per day
    def process_record_for_partial_upload(arr, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
      contract_no = arr[0].to_i
      company_symbol = arr[1]
      buyer_broking_firm_code = arr[2]
      seller_broking_firm_code = arr[3]
      client_name = arr[4]
      client_nepse_code = arr[5].upcase
      share_quantity = arr[6].to_i
      share_rate = arr[7]
      share_net_amount = arr[8]
      #TODO look into the usage of arr[9] (Stock Commission)
      # commission = arr[9]
      bank_deposit = arr[10]
      # arr[11] = NIL
      is_purchase = false

      dp = 0
      bill = nil
      type_of_transaction = @@transaction_type_buying

      client = ClientAccount.unscoped.find_by!(nepse_code: client_nepse_code)

      # client branch id is used to enforce branch cost center
      client_branch_id = client.branch_id

      # check for the bank deposit value which is available only for buying
      # used 25.0 instead of 25 to get number with decimal
      # hash_dp_count is used for the dp charges
      # hash_dp is used to group transactions into bill
      # bill contains all the transactions done for a user for each type( purchase / sales)
      if bank_deposit.blank?
        # Sales
        dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'selling']
        type_of_transaction = @@transaction_type_selling
      else
        # Purchase
        is_purchase = true
        # create or find a bill by the number
        dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'buying']

        # group all the share transactions for a client for the day
        # The following if logic is first for the first purchase transaction for a client
        if hash_dp.key?(client_nepse_code+'buying')
          bill = find_or_create_bill(hash_dp[client_nepse_code+'buying'],fy_code,@date,client.id)
        else
          # The following sets key for a client during her first purchase transaction iteration.
          # Account for pre-processed relevant share transactions' associate bill for the date.
          _bill_number = nil
          pre_processed_relevant_share_transactions = ShareTransaction.where(
              date: @date,
              client_account_id: client.id,
              transaction_type: ShareTransaction.transaction_types[:buying]
          )
          if pre_processed_relevant_share_transactions.size > 0
            _bill_number = pre_processed_relevant_share_transactions.first.bill.bill_number
          else
            _bill_number = @bill_number
            @bill_number += 1
          end
          hash_dp[client_nepse_code+'buying'] = _bill_number
          bill = find_or_create_bill(_bill_number,fy_code,date,client.id) do |b|
            b.bill_type = Bill.bill_types['purchase']
            b.client_name = client_name
            b.branch_id = client_branch_id
          end
        end
      end

      # amount: amount of the transaction
      # commission: Broker commission
      # nepse: nepse commission
      # tds: tds amount deducted from the broker commission
      # sebon: sebon fee
      # bank_deposit: deposit to nepse
      cgt = 0
      amount = share_net_amount

      commission = get_commission(amount, commission_info)
      commission_rate = get_commission_rate(amount, commission_info)

      # redundant for now
      # compliance_fee = compliance_fee(commission, @date)
      # commission for broker for the transaction
      broker_purchase_commission = broker_commission(commission, commission_info)
      nepse = nepse_commission_amount(commission, commission_info)

      tds = broker_purchase_commission * 0.15

      # # since compliance fee is debit from broker purchase commission
      # # reduce amount of the purchase commission in the system.
      # purchase_commission = broker_purchase_commission - compliance_fee
      sebon = amount * 0.00015
      bank_deposit = nepse + tds + sebon + amount

      # amount to be debited to client account
      # @client_dr = nepse + sebon + amount + broker_purchase_commission + dp
      @client_dr = (bank_deposit + broker_purchase_commission - tds + dp) if bank_deposit.present?

      # get company information to store in the share transaction
      company_info = IsinInfo.find_or_create_new_by_symbol(company_symbol)

      # TODO: Include base price

      transaction = ShareTransaction.create(
          contract_no: contract_no,
          isin_info_id: company_info.id,
          buyer: buyer_broking_firm_code,
          seller: seller_broking_firm_code,
          raw_quantity: share_quantity,
          quantity: share_quantity,
          share_rate: share_rate,
          share_amount: share_net_amount,
          sebo: sebon,
          commission_rate: commission_rate,
          commission_amount: commission,
          dp_fee: dp,
          cgt: cgt,
          net_amount: @client_dr, #calculated as @client_dr = nepse + sebon + amount + purchase_commission + dp. Not to be confused with share_amount
          bank_deposit: bank_deposit,
          transaction_type: type_of_transaction,
          date: @date,
          client_account_id: client.id,
          branch_id: client_branch_id
      )
      update_share_inventory(client.id, company_info.id, transaction.quantity, transaction.buying?)

      bill_id = nil
      bill_number = nil
      full_bill_number = nil

      if type_of_transaction ==   @@transaction_type_buying
        bill.share_transactions << transaction
        bill.net_amount += transaction.net_amount
        bill.balance_to_pay += transaction.net_amount
        if bill.partial? || bill.settled?
          bill.status = Bill.statuses[:partial]
        end
        bill.settlement_date = settlement_date
        bill.save!
        bill_id = bill.id
        full_bill_number = "#{fy_code}-#{bill.bill_number}"

        client_group = Group.find_or_create_by!(name: "Clients")
        # create client ledger if not exist
        client_ledger = Ledger.find_or_create_by!(client_code: client_nepse_code) do |ledger|
          ledger.name = client_name
          ledger.client_account_id = client.id
          ledger.group_id = client_group.id
        end

        # find or create predefined ledgers
        purchase_commission_ledger = find_or_create_ledger_by_name( "Purchase Commission")
        nepse_ledger = find_or_create_ledger_by_name( "Nepse Purchase")
        tds_ledger = find_or_create_ledger_by_name( "TDS")
        dp_ledger = find_or_create_ledger_by_name("DP Fee/ Transfer")
        compliance_ledger = find_or_create_ledger_by_name("Compliance Fee")


        # update description
        description = "Shares purchased (#{share_quantity}*#{company_symbol}@#{share_rate}) for #{client_name}"
        # update ledgers value
        # voucher date will be today's date
        # bill date will be earlier
        voucher = Voucher.create!(date: @date, date_bs: ad_to_bs_string(@date))
        voucher.bills_on_creation << bill
        voucher.share_transactions << transaction
        voucher.desc = description
        voucher.complete!
        voucher.save!

        #TODO replace bill from particulars with bill from voucher
        process_accounts(client_ledger, voucher, true, @client_dr, description, client_branch_id, @date)
        # process_accounts(compliance_ledger, voucher, false, compliance_fee, description,client_branch_id, @date) if compliance_fee > 0
        process_accounts(tds_ledger, voucher, true, tds, description, client_branch_id, @date)
        process_accounts(purchase_commission_ledger, voucher, false, broker_purchase_commission, description, client_branch_id, @date)
        process_accounts(dp_ledger, voucher, false, dp, description, client_branch_id, @date) if dp > 0
        process_accounts(nepse_ledger, voucher, false, bank_deposit, description,client_branch_id, @date)

      end


      arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
    end

    def find_or_create_bill(bill_number, fy_code, date, client_account_id)
      Bill.unscoped.find_or_create_by!(
          bill_number: bill_number,
          fy_code: fy_code,
          date: date,
          client_account_id: client_account_id) do |b|
        yield b
      end
    end
    # return true if the floor sheet data is invalid
    def is_invalid_file_data(xlsx)
      file_info = xlsx.sheet(0).row(4)
      return true unless file_info.include?("Broker-Wise Floor Sheet")
      xlsx.sheet(0).row(11)[1].to_s.tr(' ', '') != 'Contract No.' && xlsx.sheet(0).row(12)[0].nil?
    end

    def find_or_create_ledger_by_name(name)
      Ledger.find_or_create_by!(name: name)
    end

    # Get a unique bill number based on fiscal year
    # The returned bill number is an increment (by 1) of the previously stored bill_number.
    def get_bill_number(fy_code = get_fy_code)
      Bill.new_bill_number(fy_code)
    end

    def new_client_accounts_error_message(new_client_accounts)
      error_message = "FLOORSHEET IMPORT CANCELLED!<br>New client accounts found in the file!<br>"
      error_message += "Please manually create the client accounts for the following in the system first, before re-uploading the floorsheet.<br>"
      error_message += "If applicable, please make sure to assign the correct branch to the client account so that billing is tagged to the appropriate branch.<br>"
      error_message.html_safe
    end

  end
