#TODO (subas): Move 'is already uploaded file' logic FROM after open_file completion TO right after the first valid row in excel is parsed.

class FilesImportServices::ImportFloorsheet  < ImportFile
  attr_reader :date, :error_type, :new_client_accounts
  # process the file
  include CommissionModule
  include ShareInventoryModule
  include ApplicationHelper

  FILETYPE = FileUpload::file_types[:floorsheet]

  # amount above which it has to be settled within brokers.
  THRESHOLD_NEPSE_AMOUNT_LIMIT = 5000000
  def initialize(file, is_partial_upload = false)
    @date = nil
    @is_partial_upload = is_partial_upload
    super(file)
  end


  def process
    if @is_partial_upload
      process_partial
    else
      process_full
    end
  end

  def process_full
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
    date_data = xlsx.sheet(0).row(12)[3].to_s
    # convert a string to date
    @date = Date.parse("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")


    # TODO remove this
    @older_detected= false
    if @date.nil?
      @older_detected = true
      date_data = xlsx.sheet(0).row(12)[0].to_s
      @date = Date.parse("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")
    end

    import_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if (@date.nil? || (!parsable_date? @date))

    # fiscal year and date should match
    # file_error("Please change the fiscal year.") and return unless date_valid_for_fy_code(@date)
    unless date_valid_for_fy_code(@date)
      import_error("Please change the fiscal year.") and return
    end

    # do not reprocess file if it is already uploaded
    floorsheet_file = FileUpload.find_by(file_type: FILETYPE, report_date: @date)
    # raise soft error and return if the file is already uploaded
    import_error("The file is already uploaded") and return unless floorsheet_file.nil?

    settlement_date = Calendar::t_plus_3_trading_days(@date)
    fy_code = get_fy_code(@date)

    # get bill number once and increment it on rails code
    # dont do database query for each creation
    @bill_number = get_bill_number(fy_code)

    # loop through 13th row to last row
    # parse the data
    @total_amount = 0

    new_client_accounts = []
    data_sheet = xlsx.sheet(0)
    (12..(data_sheet.last_row)).each do |i|

      row_data = data_sheet.row(i)
      # break if row with Total is found
      if (row_data[0].to_s.tr(' ', '') == 'Total')
        @total_amount = row_data[21].to_f
        break
      end

      break if row_data[0] == nil
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
      # TODO remove this hack
      if @older_detected
        @raw_data << [row_data[0], row_data[1], row_data[2], row_data[3], row_data[4], row_data[5], row_data[6], row_data[7], row_data[8], row_data[9], row_data[10]]
        @total_amount_file = 0
        company_symbol = row_data[1]
        client_name = row_data[4]
        client_nepse_code = row_data[5].upcase
        bank_deposit = row_data[10]
      else
        @raw_data << [row_data[3], row_data[7], row_data[8], row_data[10], row_data[12], row_data[15], row_data[17], row_data[19], row_data[20], row_data[23], row_data[26]]
        # sum of the amount section should be equal to the calculated sum
        @total_amount_file = @raw_data.map { |d| d[8].to_f }.reduce(0, :+)
        company_symbol = row_data[7]
        client_name = row_data[12]
        client_nepse_code = row_data[15].upcase
        bank_deposit = row_data[26]
      end

      # check for the bank deposit value which is available only for buying
      # store the count of transaction for unique client,company, and type of transaction
      transaction_type = bank_deposit.nil? ? :selling : :buying
      hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] += 1

      # Maintain list of new client accounts not in the system yet.
      unless ClientAccount.unscoped.find_by(nepse_code: client_nepse_code)
        client_account_hash = {client_name: client_name, client_nepse_code: client_nepse_code}
        unless new_client_accounts.include?(client_account_hash)
          new_client_accounts << client_account_hash
        end
      end

    end

    # Client information should be available before file upload.
    unless new_client_accounts.blank?
      @error_type = 'new_client_accounts_present'
      @new_client_accounts = new_client_accounts
      import_error(new_client_accounts_error_message(new_client_accounts)) and return
    end

    import_error("The amounts don't match up.") and return if (@total_amount_file - @total_amount).abs > 0.1

    begin

      commission_info = get_commission_info_with_detail(@date)
    # rescue
    #   import_error("Commission Rates not found for the required date #{@date.to_date}") and return
    end


    # critical functionality happens here
    ActiveRecord::Base.transaction do
      @raw_data.each do |arr|
        @processed_data << process_record_for_full_upload(arr, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
      end
      # create_sms_result = CreateSmsService.new(floorsheet_records: @processed_data, transaction_date: @date, broker_code: current_tenant.broker_code).process
      FileUpload.find_or_create_by!(file_type: FILETYPE, report_date: @date)
    end

    # # used to fire error when floorsheet contains client data but not mapped to system
    # file_error(@error_message) if @error_message.present?
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
    type_of_transaction = ShareTransaction.transaction_types['buying']

    client = ClientAccount.unscoped.find_by!(nepse_code: client_nepse_code)

    # client branch id is used to enforce branch cost center
    client_branch_id = client.branch_id

    # check for the bank deposit value which is available only for buying
    # used 25.0 instead of 25 to get number with decimal
    # hash_dp_count is used for the dp charges
    # hash_dp is used to group transactions into bill
    # bill contains all the transactions done for a user for each type( purchase / sales)
    if bank_deposit.nil?
      dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'selling']
      type_of_transaction = ShareTransaction.transaction_types['selling']
    else
      is_purchase = true
      # create or find a bill by the number
      dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'buying']
      # group all the share transactions for a client for the day
      if hash_dp.key?(client_nepse_code+'buying')
        bill = Bill.unscoped.find_or_create_by!(
            bill_number: hash_dp[client_nepse_code+'buying'],
            fy_code: fy_code,
            date: @date,
            client_account_id: client.id)
      else
        hash_dp[client_nepse_code+'buying'] = @bill_number
        bill = Bill.unscoped.find_or_create_by!(
            bill_number: @bill_number,
            fy_code: fy_code,
            client_account_id: client.id,
            date: @date
        ) do |b|
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
        client_account_id: client.id
    )
    # TODO(sarojk): Find a way to fix for pre-uploaded(or pre-processed) share transactions.
    update_share_inventory(client.id, company_info.id, transaction.quantity, transaction.buying?)

    bill_id = nil
    bill_number = nil
    full_bill_number = nil

    if type_of_transaction == ShareTransaction.transaction_types['buying']
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
      purchase_commission_ledger = Ledger.find_or_create_by!(name: "Purchase Commission")
      nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
      tds_ledger = Ledger.find_or_create_by!(name: "TDS")
      dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
      compliance_ledger = Ledger.find_or_create_by!(name: "Compliance Fee")


      # update description
      description = "Shares purchased (#{share_quantity}*#{company_symbol}@#{share_rate})"
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

      #   special case for nepse incase of a threshold transfer
      #   settlement is done with the broker itself and not the nepse
      #   only settlement done is the commission and tds.
      unless share_net_amount < THRESHOLD_NEPSE_AMOUNT_LIMIT
        new_description = "Buy Adjustment with Broker #{seller_broking_firm_code} (#{share_quantity}*#{company_symbol}@#{share_rate})"
        additional_voucher = Voucher.create!(date: @date, date_bs: ad_to_bs_string(@date))
        additional_voucher.share_transactions << transaction
        additional_voucher.desc = description
        clearing_ledger = Ledger.find_or_create_by!(name: "Clearing Account")
        process_accounts(nepse_ledger, voucher, true, THRESHOLD_NEPSE_AMOUNT_LIMIT, description, client_branch_id, transaction.date)
        process_accounts(clearing_ledger, voucher, false, THRESHOLD_NEPSE_AMOUNT_LIMIT, description, client_branch_id, transaction.date)
        additional_voucher.complete!
        additional_voucher.save!
      end
    end


    arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
  end

  def process_partial
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
    date_data = xlsx.sheet(0).row(12)[3].to_s
    # convert a string to date
    @date = Date.parse("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")


    # TODO remove this
    @older_detected= false
    if @date.nil?
      @older_detected = true
      date_data = xlsx.sheet(0).row(12)[0].to_s
      @date = Date.parse("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")
    end

    import_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if (@date.nil? || (!parsable_date? @date))

    # fiscal year and date should match
    # file_error("Please change the fiscal year.") and return unless date_valid_for_fy_code(@date)
    unless date_valid_for_fy_code(@date)
      import_error("Please change the fiscal year.") and return
    end

    settlement_date = Calendar::t_plus_3_trading_days(@date)
    fy_code = get_fy_code(@date)

    # get bill number once and increment it on rails code
    # dont do database query for each creation
    @bill_number = get_bill_number(fy_code)

    # loop through 13th row to last row
    # parse the data
    @total_amount = 0
    @partial_total_amount = 0
    @total_amount_file = 0
    new_client_accounts = []
    data_sheet = xlsx.sheet(0)
    (12..(data_sheet.last_row)).each do |i|

      row_data = data_sheet.row(i)
      # break if row with Total is found
      if (row_data[0].to_s.tr(' ', '') == 'Total')
        @total_amount = row_data[21].to_f
        break
      end

      break if row_data[0] == nil

      # If share transaction already in db, skip it!
      _contract_no = row_data[3].to_i
      if ShareTransaction.find_by_contract_no(_contract_no).present?
        @partial_total_amount += row_data[20]
        next
      end

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
      # TODO remove this hack
      if @older_detected
        @raw_data << [row_data[0], row_data[1], row_data[2], row_data[3], row_data[4], row_data[5], row_data[6], row_data[7], row_data[8], row_data[9], row_data[10]]
        @total_amount_file = 0
        company_symbol = row_data[1]
        client_name = row_data[4]
        client_nepse_code = row_data[5].upcase
        bank_deposit = row_data[10]
      else
        @raw_data << [row_data[3], row_data[7], row_data[8], row_data[10], row_data[12], row_data[15], row_data[17], row_data[19], row_data[20], row_data[23], row_data[26]]
        # sum of the amount section should be equal to the calculated sum
        @total_amount_file = @raw_data.map { |d| d[8].to_f }.reduce(0, :+)
        company_symbol = row_data[7]
        client_name = row_data[12]
        client_nepse_code = row_data[15].upcase
        bank_deposit = row_data[26]
      end

      # Check for the bank deposit value which is available only for buying
      transaction_type = bank_deposit.nil? ? :selling : :buying

      # Store the count of transaction for unique client,company, and type of transaction
      # Also, account for share transactions already in the db.
      # `**_counted_from_db` is flag to check whether or not that group of share transaction has been accounted for.
      client = ClientAccount.unscoped.find_by(nepse_code: client_nepse_code)
      if client.present?
        if hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s + '_counted_from_db'] == 0
          company_info = IsinInfo.find_or_create_new_by_symbol(company_symbol)
          relevant_share_transactions_count = ShareTransaction.where(
              date: @date,
              client_account_id: client.id,
              isin_info_id: company_info.id,
              transaction_type: ShareTransaction.transaction_types[transaction_type]
          ).size
          hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] = relevant_share_transactions_count
          # Switch the flag `**_counted_from_db` to true
          hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s + '_counted_from_db'] = 1
        end
        hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] += 1
      else
        # Maintain list of new client accounts not in the system yet.
        client_account_hash = {client_name: client_name, client_nepse_code: client_nepse_code}
        unless new_client_accounts.include?(client_account_hash)
          new_client_accounts << client_account_hash
        end
      end
    end

    # Client information should be available before file upload.
    unless new_client_accounts.blank?
      @error_type = 'new_client_accounts_present'
      @new_client_accounts = new_client_accounts
      import_error(new_client_accounts_error_message(new_client_accounts)) and return
    end

    @total_amount_file += @partial_total_amount

    import_error("The amounts don't match up.") and return if (@total_amount_file - @total_amount).abs > 0.1

    begin

      commission_info = get_commission_info_with_detail(@date)
      # rescue
      #   import_error("Commission Rates not found for the required date #{@date.to_date}") and return
    end


    # critical functionality happens here
    ActiveRecord::Base.transaction do
      # Store already processed share transactions (from earlier partial upload).
      processed_share_transactions_for_the_date = ShareTransaction.where(date: @date)
      @raw_data.each do |arr|
        @processed_data << process_record_for_partial_upload(arr, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
      end
      repatch_share_transactions_accomodating_partial_upload(processed_share_transactions_for_the_date)
      # create_sms_result = CreateSmsService.new(floorsheet_records: @processed_data, transaction_date: @date, broker_code: current_tenant.broker_code).process
      FileUpload.find_or_create_by!(file_type: FILETYPE, report_date: @date)
    end

    # # used to fire error when floorsheet contains client data but not mapped to system
    # file_error(@error_message) if @error_message.present?
  end

  def repatch_share_transactions_accomodating_partial_upload(processed_share_transactions_for_the_date)
    processed_share_transactions_for_the_date.each do |share_transaction|

      # Patch dp fee in share transaction (but not quite yet on voucher)
      relevant_share_transactions_count = ShareTransaction.where(
          date: share_transaction.date,
          client_account_id: share_transaction.client_account.id,
          isin_info_id: share_transaction.isin_info.id,
          transaction_type: ShareTransaction.transaction_types[share_transaction.transaction_type]
      ).size
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
        dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
        process_accounts(dp_ledger, new_voucher, true,  difference_of_dp_fee_for_st, description, share_transaction.client_account.branch_id, @date)

        # Re-adjusting of  bill not needed, as dp fee for a bill is calculated through its share transactions (on the fly).
      end

    end
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
    type_of_transaction = ShareTransaction.transaction_types['buying']

    client = ClientAccount.unscoped.find_by!(nepse_code: client_nepse_code)

    # client branch id is used to enforce branch cost center
    client_branch_id = client.branch_id

    # check for the bank deposit value which is available only for buying
    # used 25.0 instead of 25 to get number with decimal
    # hash_dp_count is used for the dp charges
    # hash_dp is used to group transactions into bill
    # bill contains all the transactions done for a user for each type( purchase / sales)
    if bank_deposit.nil?
      # Sales
      dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'selling']
      type_of_transaction = ShareTransaction.transaction_types['selling']
    else
      # Purchase
      is_purchase = true
      # create or find a bill by the number
      dp = 25.0 / hash_dp_count[client_nepse_code+company_symbol.to_s+'buying']

      # group all the share transactions for a client for the day
      # The following if logic is first for the first purchase transaction for a client
      if hash_dp.key?(client_nepse_code+'buying')
        bill = Bill.unscoped.find_or_create_by!(
            bill_number: hash_dp[client_nepse_code+'buying'],
            fy_code: fy_code,
            date: @date,
            client_account_id: client.id)
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
        bill = Bill.unscoped.find_or_create_by!(
            bill_number: _bill_number,
            fy_code: fy_code,
            client_account_id: client.id,
            date: @date
        ) do |b|
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
        client_account_id: client.id
    )
    update_share_inventory(client.id, company_info.id, transaction.quantity, transaction.buying?)

    bill_id = nil
    bill_number = nil
    full_bill_number = nil

    if type_of_transaction == ShareTransaction.transaction_types['buying']
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
      purchase_commission_ledger = Ledger.find_or_create_by!(name: "Purchase Commission")
      nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
      tds_ledger = Ledger.find_or_create_by!(name: "TDS")
      dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
      compliance_ledger = Ledger.find_or_create_by!(name: "Compliance Fee")


      # update description
      description = "Shares purchased (#{share_quantity}*#{company_symbol}@#{share_rate})"
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

      #   special case for nepse incase of a threshold transfer
      #   settlement is done with the broker itself and not the nepse
      #   only settlement done is the commission and tds.
      unless share_net_amount < THRESHOLD_NEPSE_AMOUNT_LIMIT
        new_description = "Buy Adjustment with Broker #{seller_broking_firm_code} (#{share_quantity}*#{company_symbol}@#{share_rate})"
        additional_voucher = Voucher.create!(date: @date, date_bs: ad_to_bs_string(@date))
        additional_voucher.share_transactions << transaction
        additional_voucher.desc = description
        clearing_ledger = Ledger.find_or_create_by!(name: "Clearing Account")
        process_accounts(nepse_ledger, voucher, true, THRESHOLD_NEPSE_AMOUNT_LIMIT, description, client_branch_id, transaction.date)
        process_accounts(clearing_ledger, voucher, false, THRESHOLD_NEPSE_AMOUNT_LIMIT, description, client_branch_id, transaction.date)
        additional_voucher.complete!
        additional_voucher.save!
      end
    end


    arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
  end

  # return true if the floor sheet data is invalid
  def is_invalid_file_data(xlsx)
    xlsx.sheet(0).row(11)[1].to_s.tr(' ', '') != 'Contract No.' && xlsx.sheet(0).row(12)[0].nil?
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
