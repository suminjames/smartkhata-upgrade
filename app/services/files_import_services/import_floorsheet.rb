class FilesImportServices::ImportFloorsheet  < ImportFile
  attr_reader :date, :error_type, :new_client_accounts, :acting_user, :selected_fy_code, :value_date, :bill_ids, :ledger_ids

  include CommissionModule
  include ShareInventoryModule
  include ApplicationHelper

  FILETYPE = FileUpload::file_types[:floorsheet]
  @@transaction_type_buying = ShareTransaction.transaction_types['buying']
  @@transaction_type_selling =  ShareTransaction.transaction_types['selling']

  def initialize(file, acting_user , selected_fy_code, is_partial_upload = false)
    @date = nil
    @acting_user = acting_user
    @is_partial_upload = is_partial_upload
    @selected_fy_code = selected_fy_code
    # @value_date = value_date
    @bill_ids = []
    @ledger_ids = []
    @missing_symbols =[]
    super(file)
  end

  def tplus2(date)
    new_date = date + 2.days
    new_date.wday == 6 ? new_date + 1 : new_date
  end

  def set_value_date(date)
    @value_date = tplus2(date)
  end

  def process
    process_full_partial(@is_partial_upload)
  end

  def process_full_partial(is_partial)
    # read the xls file
    xlsx = Roo::Spreadsheet.open(@file, extension: :xml)

    # hash to store unique combination of isin, transaction type (buying/selling), client
    hash_dp_count = Hash.new 0
    hash_dp = Hash.new

    @raw_data = []

    import_error("Please verify and Upload a valid file") and return if (is_invalid_file_data(xlsx))
    # grab date from the first record
    date_data = date_from_excel(xlsx)
    # convert a string to date
    @date = Date.parse(date_data) if date_data.present? && parsable_date?(date_data)

    import_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if @date.nil?
    # fiscal year and date should match
    unless date_valid_for_fy_code(@date, selected_fy_code)
      import_error("Please change the fiscal year.") and return
    end

    set_value_date(@date)
    # unless date_valid_for_fy_code(@value_date, selected_fy_code, tplus3(@date))
    #   import_error("Value date must not be earlier than the T+3 of transaction date") and return
    # end
    #

    if !is_partial
      # do not reprocess file if it is already uploaded
      floorsheet_file = FileUpload.find_by(file_type: FILETYPE, report_date: @date)
      # raise soft error and return if the file is already uploaded
      import_error("The file is already uploaded") and return unless floorsheet_file.nil?
    end
    settlement_date = Calendar::t_plus_3_working_days(@date)
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
      data_hash = relevant_data_hash(row_data)

      contract_no = data_hash[:contract_no]
      break if contract_no.blank?

      import_error("File contains invalid data") and return if is_relevant_data_invalid?(data_hash)

      if is_partial
        # If share transaction already in db, skip it!
        if ShareTransaction.find_by_contract_no(contract_no).present?
          next
        end
      end

      @raw_data << data_hash

      company_symbol, client_name, client_nepse_code, bank_deposit = selected_columns_from_data_hash(data_hash, %i[company_symbol client_name client_nepse_code bank_deposit])
      client_nepse_code = client_nepse_code.strip.upcase

      # check for the bank deposit value which is available only for buying
      # store the count of transaction for unique client,company, and type of transaction
      transaction_type = bank_deposit.blank? ? :selling : :buying

      # early return if symbol missing in db
      company_info = IsinInfo.find_by(isin: company_symbol)
      unless company_info.present?
        @missing_symbols |= [company_symbol]
        next
      end

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
            hash_dp_count_increment(transaction_type,client,company_symbol,client_nepse_code,hash_dp_count, company_info)
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

    # IsinInfo check
    if @missing_symbols.present?
      import_error("Missing Company Data for #{@missing_symbols.join(',')}") and return
    end

    commission_info = {
      regular: get_commission_info_with_detail(@date, :regular),
      debenture:   get_commission_info_with_detail(@date, :debenture),
      mutual_funds: get_commission_info_with_detail(@date, :mutual_funds)
    }


    # critical functionality happens here
    ActiveRecord::Base.transaction do
      @raw_data.each do |data_hash|
        process_record_for_full_upload(data_hash, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info)
      end
      generate_vouchers

      FileUpload.create!(file_type: FILETYPE, report_date: @date, current_user_id: @acting_user.id, value_date: value_date)
    end
  end

  # rawdata =[
  #     Serial
  #   	Contract No.,
  #   	Symbol,
  #   	Buyer Broking Firm Code,
  #   	Seller Broking Firm Code,
  #   	Client Name,
  #   	Client Code,
  #   	Quantity,
  #   	Rate,
  #   	Amount,
  #   	Stock Comm.,
  #   	Bank Deposit,
  #   ]

  # hash from array of relevant data
  def relevant_data_hash(data)
    data_row_keys.zip(data).to_h.tap do |hash|
      hash[:client_nepse_code] = hash[:client_nepse_code].upcase if hash[:client_nepse_code].present?
    end
  end

  def data_row_keys
    %i[serial contract_no company_symbol buyer seller client_name client_nepse_code quantity rate amount commission bank_deposit]
  end

  # returns array
  def selected_columns_from_data_hash(data_hash, keys)
    data_hash.slice(*keys).values
  end

  def is_relevant_data_invalid? data_hash
    required_data_array = data_hash.except(:serial, :bank_deposit).values
    required_data_array.select{|x| x.blank? }.present? ||
      !equal_amounts?(data_hash[:amount], data_hash[:rate] * data_hash[:quantity])
  end


  def add_client_account(client_name,client_nepse_code,new_client_accounts)
    client_account_hash = {client_name: client_name, client_nepse_code: client_nepse_code}
    unless new_client_accounts.include?(client_account_hash)
      new_client_accounts << client_account_hash
      # ClientAccount.create(current_user_id: 1, branch_id: 1, name: client_name, nepse_code: client_nepse_code)
    end
  end

  def hash_dp_count_increment(transaction_type,client,company_symbol,client_nepse_code,hash_dp_count, company_info)
    relevant_share_transactions_count = relevant_share_transactions_count(@date,client.id,company_info.id, ShareTransaction.transaction_types[transaction_type] )

    hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s] = relevant_share_transactions_count
    # Switch the flag `**_counted_from_db` to true
    hash_dp_count[client_nepse_code + company_symbol.to_s + transaction_type.to_s + '_counted_from_db'] = 1
  end



  # def commission_info_by_group(company, commission_info)
  #   commission_info[company.commission_group]
  # end

  # hash_dp => custom hash to store unique isin , buying/selling, customer per day
  def process_record_for_full_upload(data_hash, hash_dp, fy_code, hash_dp_count, settlement_date, commission_info_group)
    _serial,
      contract_no,
      company_symbol,
      buyer_broking_firm_code,
      seller_broking_firm_code,
      client_name,
      client_nepse_code,
      share_quantity,
      share_rate,
      share_net_amount,
      _commission,
      bank_deposit = selected_columns_from_data_hash(data_hash, data_row_keys)

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

    # get company information to store in the share transaction
    company_info = IsinInfo.find_by(isin: company_symbol)


    commission_info = commission_info_group[company_info.commission_group]
    commission_rate = get_commission_rate(amount, commission_info, _commission)
    # commission_rate = get_commission_rate_from_floorsheet(amount, _commission, commission_info)
    commission = get_commission_by_rate( commission_rate, amount).round(2)
    nepse = nepse_commission_amount(commission, commission_info)
    broker_purchase_commission = commission - nepse

    tds = broker_purchase_commission * 0.15

    # # since compliance fee is debit from broker purchase commission
    # # reduce amount of the purchase commission in the system.
    # purchase_commission = broker_purchase_commission - compliance_fee
    sebon = sebo_amount(amount, commission_info)
    bank_deposit = nepse + tds + sebon + amount

    # amount to be debited to client account
    # @client_dr = nepse + sebon + amount + broker_purchase_commission + dp
    @client_dr = (bank_deposit + broker_purchase_commission - tds + dp) if bank_deposit.present?

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
        branch_id: client_branch_id,
        current_user_id: @acting_user.id
    )

    if type_of_transaction == @@transaction_type_buying
      bill.share_transactions << transaction
      bill.net_amount += transaction.net_amount
      bill.balance_to_pay = bill.net_amount
      bill.settlement_date = settlement_date
      bill.save!
      @bill_ids |= [bill.id]
    end

    # arr = Array.new
    # data_hash.each do |key, value|
    #   arr.push(value)
    # end
    #
    #  arr.push(@client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, @date, client.id, full_bill_number, transaction)
    # #true

  end

  def generate_vouchers(relevant_bill_ids = @bill_ids)
    client_group = Group.find_or_create_by!(name: "Clients")
    purchase_commission_ledger =find_or_create_ledger_by_name("Purchase Commission")
    nepse_ledger = find_or_create_ledger_by_name("Nepse Purchase")
    tds_ledger = find_or_create_ledger_by_name("TDS")
    dp_ledger = find_or_create_ledger_by_name("DP Fee/ Transfer")
    rounding_ledger = find_or_create_ledger_by_name( "Rounding Off Difference")
    # find or create predefined ledgers

    Bill.where(id: relevant_bill_ids).find_each do |bill|
      client_account = bill.client_account

      client_ledger = get_client_ledger(client_account, client_account.nepse_code, client_account.name, client_group)

      transactions = bill.share_transactions.includes(:isin_info).group(:isin_info_id).weighted_average(:share_rate)

      date_of_transaction = @date || bill.date
      bill_value_date = value_date || tplus3(date_of_transaction)

      description = transactions.map do |st|
        "#{st.quantity}*#{st.isin_info.isin}@#{st.wa_share_rate.round(2)}"
      end.join(',')

      # update description
      description = "Shares purchased (#{description})  for #{client_account.name}"

      # update ledgers value
      # voucher date will be today's date
      # bill date will be earlier

      client_branch_id = client_account.branch_id

      voucher = Voucher.create!(date: date_of_transaction, date_bs: ad_to_bs_string(date_of_transaction), branch_id: client_branch_id, current_user_id: @acting_user.id)
      voucher.bills_on_creation << bill
      voucher.share_transactions = bill.share_transactions
      voucher.desc = description
      voucher.complete!
      voucher.save!

      tds = transactions.map{|h| h['tds']}.inject(:+).round(2)
      dp = transactions.map{|h| h['dp_fee']}.inject(:+).round
      nepse_commission = transactions.map{|h| h['nepse_commission']}.inject(:+).round(2)
      commission_amount = transactions.map{|h| h['commission_amount']}.inject(:+).round(2)
      # sebo = transactions.map{|h| h['sebo']}.inject(:+)
      bank_deposit = transactions.map{|h| h['bank_deposit']}.inject(:+).round(2)
      broker_purchase_commission = commission_amount - nepse_commission

      bill_net_amount = bill.rounded_net_amount
      rounding = bill_net_amount + tds - ( broker_purchase_commission + dp + bank_deposit )


      if(rounding.abs != 0)
        process_accounts(rounding_ledger, voucher, rounding < 0, rounding.abs, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date)
      end

      process_accounts(client_ledger, voucher, true, bill_net_amount, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date)
      process_accounts(tds_ledger, voucher, true, tds, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date)
      process_accounts(purchase_commission_ledger, voucher, false, broker_purchase_commission, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date)
      process_accounts(dp_ledger, voucher, false, dp, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date) if dp > 0
      process_accounts(nepse_ledger, voucher, false, bank_deposit, description, client_branch_id, date_of_transaction, @acting_user, bill_value_date)
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

  def find_or_create_bill(bill_number, fy_code, date, client_account_id)
    Bill.find_or_create_by!(
        bill_number: bill_number,
        fy_code: fy_code,
        date: date,
        updater_id: @acting_user&.id,
        creator_id: @acting_user&.id,
        client_account_id: client_account_id) do |b|
          yield b
        end
  end
  # return true if the floor sheet data is invalid
  def is_invalid_file_data(xlsx)
    file_info = xlsx.sheet(0).row(4)
    return true unless file_info.include?("Broker-Wise Floor Sheet")
    row_count = xlsx.sheet(0).count rescue 0
    # records start from 7th row  and we have 1 more row for total
    # hence to have some meaningful data the count of rows should be more than 7
    return true unless row_count > 7
    xlsx.sheet(0).row(7)[1].to_s.tr(' ', '') != 'Contract No.' && xlsx.sheet(0).row(row_count)[0].nil?
  end


  def date_from_excel(xlsx)
    xlsx.sheet(0).row(5)[0][/\((.+)\)/, 1].strip rescue nil
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


  def get_client_ledger(client, client_nepse_code, client_name, client_group)
    ledger = Ledger.find_by(client_account_id: client.id, client_code: client_nepse_code)
    ledger ||= client.ledger
    ledger ||= Ledger.find_or_create_by!(client_code: client_nepse_code) do |ledger|
      ledger.name = client_name
      ledger.client_account_id = client.id
      ledger.group_id = client_group.id
      ledger.client_code = client_nepse_code
    end
    ledger
  end
end
