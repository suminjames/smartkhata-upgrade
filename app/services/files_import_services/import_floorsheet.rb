#TODO (subas): Move 'is already uploaded file' logic FROM after open_file completion TO right after the first valid row in excel is parsed.

class FilesImportServices::ImportFloorsheet  < ImportFile
  attr_reader :date
  # process the file
  include CommissionModule
  include ShareInventoryModule
  include ApplicationHelper

  FILETYPE = FileUpload::file_types[:floorsheet]

  # amount above which it has to be settled within brokers.
  THRESHOLD_NEPSE_AMOUNT_LIMIT = 5000000
  def initialize(file)
    @date = nil
    super(file)
  end


  def process
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


      if bank_deposit.nil?
        hash_dp_count[client_nepse_code+company_symbol.to_s+'selling'] += 1
      else
        hash_dp_count[client_nepse_code+company_symbol.to_s+'buying'] += 1
      end

    end


    import_error("The amount dont match up") and return if (@total_amount_file - @total_amount).abs > 0.1

    # critical functionality happens here
    ActiveRecord::Base.transaction do
      @raw_data.each do |arr|
        @processed_data << process_records(arr, hash_dp, fy_code, hash_dp_count, settlement_date)
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
  def process_records(arr, hash_dp, fy_code, hash_dp_count, settlement_date)
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


    # TODO(Subas) remove this code block to take only the mapped user list
    client = ClientAccount.find_or_create_by!(nepse_code: client_nepse_code) do |client|
      client.name = client_name.titleize
    end


    # # client information should be available before file upload
    # client = ClientAccount.find_by(nepse_code: client_nepse_code.upcase)
    # if client.nil?
    #   @error_message = "Please map #{client_name} with nepse code #{client_nepse_code} to the system first"
    #   raise ActiveRecord::Rollback
    #   return
    # end

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
        bill = Bill.unscoped.find_or_create_by!(bill_number: hash_dp[client_nepse_code+'buying'], fy_code: fy_code, date: @date, client_account_id: client.id)
      else
        hash_dp[client_nepse_code+'buying'] = @bill_number
        bill = Bill.unscoped.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code, client_account_id: client.id, date: @date) do |b|
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
    commission = get_commission(amount, @date)
    commission_rate = get_commission_rate(amount, @date)

    # redundant for now
    # compliance_fee = compliance_fee(commission, @date)
    # commission for broker for the transaction
    broker_purchase_commission = broker_commission(commission, @date)
    nepse = nepse_commission(commission, @date)

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
    company_info = IsinInfo.find_or_create_by(isin: company_symbol)

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
end