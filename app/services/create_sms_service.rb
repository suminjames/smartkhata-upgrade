class HashTree < Hash
  def initialize
    super do |hash, key|
      hash[key] = HashTree.new
    end
  end
end

class CreateSmsService
  include CustomDateModule
  include NumberFormatterModule

  def initialize(attrs = {})
    @floorsheet_records = attrs[:floorsheet_records]
    @grouped_records = Hash.new
    @broker_code = attrs[:broker_code]
    @transaction_date = attrs[:transaction_date] || Time.now
    @transaction_date_short = ad_to_bs(@transaction_date)[5..-1].sub('-', '/')
    # needed to revert the process
    @transaction_message = attrs[:transaction_message]
    # since the amount to receive/ pay is dependent on bill
    # this is required when bill is being changed
    @bill = attrs[:bill]
    # floorsheet_records =[
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
    #   client_dr,
    #   tds,
    #   commission,
    #   bank_deposit,
    #   dp,
    #   bill_id,
    #   is_purchase,
    #   transaction_date
    #   client_id
    #   shareTransactionObject
    # ]
  end

  def process
    group_floorsheet_records
  end

  def change_message
    res = false
    # if @transaction_message.blank?
    #   return false
    # end
    share_transactions = @transaction_message.share_transactions.not_cancelled

    # if transaction message had only one share transaction
    # just soft delete the transaction message
    if share_transactions.size < 1
      @transaction_message.soft_delete
      res = true
    else
      group_share_transaction_records(share_transactions)
      new_transaction_message =iterate_grouped_transactions(@grouped_records).first
      @transaction_message.sms_message = new_transaction_message.sms_message
      @transaction_message.save!
      res = true
    end
  end

  # group by the array from floorsheet
  def group_floorsheet_records
    @floorsheet_records.each do |transaction_record|
      contract_no = transaction_record[0]
      company_symbol = transaction_record[1]
      client_name = transaction_record[4]
      client_code = transaction_record[5]
      quantity = transaction_record[6]
      rate = transaction_record[7]
      client_dr = transaction_record[11]
      bill_id = transaction_record[16]
      is_purchase = transaction_record[17]
      transaction_date = transaction_record[18]
      client_account_id = transaction_record[19]
      full_bill_number = transaction_record[20]
      share_transaction = transaction_record[21]
      transaction_type = is_purchase == true ? :buy : :sell
      if @grouped_records.key?(client_code)
        group_by_client_and_transaction_type(client_code, transaction_type, company_symbol, rate, quantity, client_dr, client_name, bill_id, client_account_id, full_bill_number, share_transaction)
      else
        client_single_record = get_client_initial_hash(transaction_type, company_symbol, rate, quantity, client_dr, share_transaction, client_name, bill_id, client_account_id, full_bill_number)
        @grouped_records[client_code] = client_single_record
      end
    end
    transaction_messages =iterate_grouped_transactions(@grouped_records)
    transaction_messages.each(&:save)
  end

  # group the share transactions
  def group_share_transaction_records(share_transactions)
    share_transactions.each do |transaction_record|
      bill = transaction_record.bill
      client_account = transaction_record.client_account


      contract_no = transaction_record.contract_no
      company_symbol = transaction_record.isin_info.isin
      client_name = client_account.name
      client_code = client_account.nepse_code
      quantity = transaction_record.quantity
      rate = transaction_record.share_rate
      client_dr = transaction_record.net_amount
      bill_id = transaction_record.bill_id
      transaction_date = transaction_record.date
      client_account_id = transaction_record.client_account_id
      full_bill_number = "#{bill.fy_code}-#{bill.bill_number}" if bill.present?
      transaction_type = transaction_record.buying? ? :buy : :sell

      if @grouped_records.key?(client_code)
        group_by_client_and_transaction_type(client_code, transaction_type, company_symbol, rate, quantity, client_dr, client_name, bill_id, client_account_id, full_bill_number, transaction_record)
      else
        client_single_record = get_client_initial_hash(transaction_type, company_symbol, rate, quantity, client_dr, transaction_record, client_name, bill_id, client_account_id, full_bill_number)
        @grouped_records[client_code] = client_single_record
      end
    end
  end

  # single initial hash record for client
  # it initializes the hash record for the first time
  def get_client_initial_hash(transaction_type, company_symbol, rate, quantity, client_dr, share_transaction,
                              client_name, bill_id, client_account_id, full_bill_number)
    client_single_record = HashTree.new
    client_single_record[:data][transaction_type][company_symbol][rate][:quantity] = quantity
    client_single_record[:data][transaction_type][company_symbol][rate][:receivable_from_client] = client_dr
    # cant use |= during first initialization
    client_single_record[:data][transaction_type][company_symbol][rate][:share_transactions] = [share_transaction]
    client_single_record[:info][:name] = client_name
    client_single_record[:info][:client_account_id] = client_account_id
    client_single_record[:info][:bill_id] = bill_id
    client_single_record[:info][:full_bill_number]= full_bill_number
    client_single_record
  end


  def group_by_client_and_transaction_type(client_code, transaction_type, company_symbol, rate, quantity, client_dr, client_name, bill_id, client_account_id, full_bill_number, share_transaction)
    if @grouped_records[client_code][:data].key? transaction_type
      if @grouped_records[client_code][:data][transaction_type].key? company_symbol
        if @grouped_records[client_code][:data][transaction_type][company_symbol].key? rate
          _record = @grouped_records[client_code][:data][transaction_type][company_symbol][rate]
          _record[:quantity] += quantity
          _record[:receivable_from_client] += client_dr
          _record[:share_transactions] |= [share_transaction]
          @grouped_records[client_code][:data][transaction_type][company_symbol][rate] = _record
        else
          _record = Hash.new
          _record[:quantity] = quantity
          _record[:receivable_from_client] = client_dr
          _record[:share_transactions] = [share_transaction]
          @grouped_records[client_code][:data][transaction_type][company_symbol][rate] = _record
        end
      else
        _record = HashTree.new
        _record[rate][:quantity] = quantity
        _record[rate][:receivable_from_client] = client_dr
        _record[rate][:share_transactions] = [share_transaction]
        @grouped_records[client_code][:data][transaction_type][company_symbol] = _record
      end
    else
      # Other type  of transaction record is present
      # Hence either append or modify the hash values
      _record = HashTree.new
      _record[company_symbol][rate][:quantity] = quantity
      _record[company_symbol][rate][:receivable_from_client] = client_dr
      _record[company_symbol][rate][:share_transactions] = [share_transaction]
      @grouped_records[client_code][:data][transaction_type] = _record

      @grouped_records[client_code][:info][:bill_id] ||= bill_id
      @grouped_records[client_code][:info][:full_bill_number] ||= full_bill_number
    end
  end

  def iterate_grouped_transactions(h)
    transaction_messages = []
    # iterate by client_code
    # key => client_code v = data for the day
    h.each do |k, v|
      info = v[:info]
      client_name = info[:name].split.first.titleize
      client_account_id = info[:client_account_id].to_i
      bill_id = info[:bill_id].to_i if info[:bill_id].present?
      share_transactions = []
      full_bill_number = info[:full_bill_number]
      transaction_data = v[:data]

      has_sales_transaction = false

      share_quantity_rate_message = ""
      total = 0.0
      # transaction data contains both buy and sell order
      transaction_data.each do |type_of_transaction, data|
        str = ""

        data.each do |symbol, symbol_data|
          str += ";#{symbol}"
          symbol_data.each do |rate, rate_data|
            str += ",#{rate_data[:quantity].to_i}@#{strip_redundant_decimal_zeroes(rate)}"
            total += rate_data[:receivable_from_client].to_f
            # merge two arrays
            share_transactions |= rate_data[:share_transactions]
          end
        end

        # hack used to remove ; from the beginning of symbol ;ccbl,1@23,2@33;nmmb,234@12
        str[0] = ""
        if type_of_transaction == :sell
          has_sales_transaction = true
          share_quantity_rate_message += ";sold #{str}"
        else
          share_quantity_rate_message += ";bought #{str}"
        end
      end
      share_quantity_rate_message[0] = ""
      sms_message = ""
      if has_sales_transaction
        sms_message = "#{client_name}, #{share_quantity_rate_message};On #{@transaction_date_short}.BNo #{@broker_code}"
      else
        # if bill is present which is true for the case of changing the message
        # override total amount with bill amount
        total = @bill.net_amount if @bill.present?
        sms_message = "#{client_name} #{share_quantity_rate_message};On #{@transaction_date_short} Bill No#{full_bill_number} .Pay Rs #{total.round(2)}.BNo #{@broker_code}"
      end

      transaction_message = TransactionMessage.new(client_account_id: client_account_id, bill_id: bill_id, transaction_date: @transaction_date, sms_message: sms_message)
      transaction_message.share_transactions << share_transactions
      transaction_messages << transaction_message

    end
    transaction_messages
  end

  # TODO (SUBAS Remove when you feel confident)
  def iterate(h)
    h.each do |k, v|
      # If v is nil, an array is being iterated and the value is k.
      # If v is not nil, a hash is being iterated and the value is v.
      #
      value = v || k

      if value.is_a?(Hash) || value.is_a?(Array)
        puts "evaluating: #{value} recursively..."
        iterate(value)
      else
        # MODIFY HERE! Look for what you want to find in the hash here
        # if v is nil, just display the array value
        puts v ? "key: #{k} value: #{v}" : "array value #{k}"
      end
    end
  end
end