#TODO: Bill status should be (be default) in pending
class Files::FloorsheetsController < Files::FilesController

  include CommissionModule
  include ShareInventoryModule

  @@file_type = FileUpload::file_types[:floorsheet]
  @@file_name_contains = "FLOORSHEET"

  def new
    floorsheets = FileUpload.where(file_type: @@file_type)
    @file_list = floorsheets.order("report_date desc").limit(Files::PREVIEW_LIMIT);
    @list_incomplete = floorsheets.count > Files::PREVIEW_LIMIT
    # if (@file_list.count > 1)
    # 	if((@file_list[0].report_date-@file_list[1].report_date).to_i > 1)
    # 		flash.now[:error] = "There is more than a day difference between last 2 reports.Please verify"
    # 	end
    # end
  end

  def index
    @file_list = FileUpload.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date DESC")
  end

  def import
    # TODO(subas): Catch invalid files where 1) all the 'data rows' are missing 2) File is 'blank'
    #              (Refer to floorsheet controller test for more info)
    #              (Sample files: test/fixtures/files/invalid_files)
    # get file from import
    @file = params[:file]
    @error_message = nil

    # grab date from the first record
    file_error("Please Upload a valid file and make sure the file name contains floorsheet") and return if (is_invalid_file(@file, @@file_name_contains))

    # read the xls file
    xlsx = Roo::Spreadsheet.open(@file, extension: :xls)

    # hash to store unique combination of isin, transaction type (buying/selling), client
    hash_dp_count = Hash.new 0
    hash_dp = Hash.new

    # array to store processed data
    @processed_data = []
    @raw_data = []

    # get bill number
    @bill_number = get_bill_number


    # grab date from the first record
    file_error("Please verify and Upload a valid file") and return if (is_invalid_file_data(xlsx))

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

    file_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if (@date.nil? || (!parsable_date? @date))

    # do not reprocess file if it is already uploaded
    floorsheet_file = FileUpload.find_by(file_type: @@file_type, report_date: @date)
    # raise soft error and return if the file is already uploaded
    file_error("The file is already uploaded") and return unless floorsheet_file.nil?

    settlement_date = Calendar::t_plus_3_trading_days(@date)

    fy_code = get_fy_code
    # loop through 13th row to last row
    # parse the data
    @total_amount = 0

    data_sheet = xlsx.sheet(0)
    (12..(data_sheet.last_row)).each do |i|

      row_data = data_sheet.row(i)

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
        bank_deposit = row_data[10]

      else
        @raw_data << [row_data[3], row_data[7], row_data[8], row_data[10], row_data[12], row_data[15], row_data[17], row_data[19], row_data[20], row_data[23], row_data[26]]
        # sum of the amount section should be equal to the calculated sum
        @total_amount_file = @raw_data.map { |d| d[8].to_f }.reduce(0, :+)
        company_symbol = row_data[7]
        client_name = row_data[12]
        bank_deposit = row_data[26]
      end

      # check for the bank deposit value which is available only for buying
      # store the count of transaction for unique client,company, and type of transaction


      if bank_deposit.nil?
        hash_dp_count[client_name.to_s+company_symbol.to_s+'selling'] += 1
      else
        hash_dp_count[client_name.to_s+company_symbol.to_s+'buying'] += 1
      end

    end


    file_error("The amount dont match up") and return if (@total_amount_file - @total_amount).abs > 0.1

    ActiveRecord::Base.transaction do
      @raw_data.each do |arr|
        @processed_data << process_records(arr, hash_dp, fy_code, hash_dp_count, settlement_date)
      end
      create_sms_result = CreateSmsService.new(floorsheet_records: @processed_data, transaction_date: @date, broker_code: current_tenant.broker_code).process
      FileUpload.find_or_create_by!(file_type: @@file_type, report_date: @date)
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
    client = ClientAccount.find_or_create_by!(nepse_code: client_nepse_code.upcase) do |client|
      client.name = client_name.titleize
    end

    # client = ClientAccount.find_by(nepse_code: client_nepse_code.upcase)
    # if client.nil?
    #   @error_message = "Please map #{client_name} with nepse code #{client_nepse_code} to the system first"
    #   raise ActiveRecord::Rollback
    #   return
    # end


    # check for the bank deposit value which is available only for buying
    # used 25.0 instead of 25 to get number with decimal
    # hash_dp_count is used for the dp charges
    # hash_dp is used to group transactions into bill
    # bill contains all the transactions done for a user for each type( purchase / sales)
    if bank_deposit.nil?
      dp = 25.0 / hash_dp_count[client_name.to_s+company_symbol.to_s+'selling']
      type_of_transaction = ShareTransaction.transaction_types['selling']
    else
      is_purchase = true
      # create or find a bill by the number
      dp = 25.0 / hash_dp_count[client_name.to_s+company_symbol.to_s+'buying']

      # group all the share transactions for a client for the day
      if hash_dp.key?(client_name.to_s+'buying')
        bill = Bill.find_or_create_by!(bill_number: hash_dp[client_name.to_s+'buying'], fy_code: fy_code, date: @date)
      else
        hash_dp[client_name.to_s+'buying'] = @bill_number
        bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code, client_account_id: client.id, date: @date) do |b|
          b.bill_type = Bill.bill_types['purchase']
          b.client_name = client_name
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
    compliance_fee = compliance_fee(commission, @date)
    purchase_commission = broker_commission(commission, @date)
    nepse = nepse_commission(commission, @date)

    tds = purchase_commission * 0.15
    sebon = amount * 0.00015
    bank_deposit = nepse + tds + sebon + amount

    # amount to be debited to client account
    # @client_dr = nepse + sebon + amount + purchase_commission + dp
    @client_dr = (bank_deposit + purchase_commission + compliance_fee - tds + dp) if bank_deposit.present?

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
    if type_of_transaction == ShareTransaction.transaction_types['buying']
      bill.share_transactions << transaction
      bill.net_amount += transaction.net_amount
      bill.balance_to_pay = bill.net_amount
      bill.settlement_date = settlement_date
      bill.save!
      bill_id = bill.id
      full_bill_number = "#{fy_code}-#{bill.bill_number}"

      # create client ledger if not exist
      client_ledger = Ledger.find_or_create_by!(client_code: client_nepse_code) do |ledger|
        ledger.name = client_name
        ledger.client_account_id = client.id
      end
      # assign the client ledgers to group clients
      client_group = Group.find_or_create_by!(name: "Clients")
      client_group.ledgers << client_ledger

      # find or create predefined ledgers
      purchase_commission_ledger = Ledger.find_or_create_by!(name: "Purchase Commission")
      nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
      tds_ledger = Ledger.find_or_create_by!(name: "TDS")
      dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")
      compliance_ledger = Ledger.find_or_create_by!(name: "Compliance Fee")


      # update description
      description = "Shares purchased (#{share_quantity}*#{company_symbol}@#{share_rate})"
      # update ledgers value
      voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
      voucher.bills_on_creation << bill
      voucher.share_transactions << transaction
      voucher.desc = description
      voucher.complete!
      voucher.save!

      #TODO replace bill from particulars with bill from voucher
      process_accounts(client_ledger, voucher, true, @client_dr, description, @date)
      process_accounts(nepse_ledger, voucher, false, bank_deposit, description, @date)
      process_accounts(compliance_ledger, voucher, false, compliance_fee, description, @date) if compliance_fee > 0
      process_accounts(tds_ledger, voucher, true, tds, description, @date)
      process_accounts(purchase_commission_ledger, voucher, false, purchase_commission, description, @date)
      process_accounts(dp_ledger, voucher, false, dp, description, @date) if dp > 0

    end


    arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
  end

  # return true if the floor sheet data is invalid
  def is_invalid_file_data(xlsx)
    xlsx.sheet(0).row(11)[1].to_s.tr(' ', '') != 'Contract No.' && xlsx.sheet(0).row(12)[0].nil?
  end
end
