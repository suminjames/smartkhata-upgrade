class HashTree < Hash
  def initialize
    super do |hash, key|
      hash[key] = HashTree.new
    end
  end
end

class CreateSmsService
  def initialize(floorsheet_records)
    @floorsheet_records = floorsheet_records
    @grouped_records = Hash.new
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
    #   settlement_date
    # ]
  end

  def process
    res = false
    group_floorsheet_records
    res
  end

  def group_floorsheet_records
    @floorsheet_records.each do |transaction_record|
      contract_no = transaction_record[0]
      symbol = transaction_record[1]
      client_name = transaction_record[4]
      client_code = transaction_record[5]
      quantity = transaction_record[6]
      rate = transaction_record[7]
      client_dr = transaction_record[11]
      bill_id = transaction_record[16]
      is_purchase = transaction_record[17]
      settlement_date = transaction_record[18]

      transaction_type = is_purchase == true ? :buy : :sell
      if @grouped_records.key?(client_code)
        group_by_client_and_transaction_type(client_code,transaction_type, symbol, rate, quantity, client_dr)
      else
        client_single_record = HashTree.new
        client_single_record[transaction_type][symbol][rate][:quantity] = quantity
        client_single_record[transaction_type][symbol][rate][:receivable_from_client] = client_dr
        @grouped_records[client_code] = client_single_record
      end
    end
  end

  def group_by_client_and_transaction_type(client_code,transaction_type, company_symbol, rate, quantity, client_dr)
    if @grouped_records[client_code].key? transaction_type
      if @grouped_records[client_code][transaction_type].key? company_symbol
        if @grouped_records[client_code][transaction_type][company_symbol].key? rate
          _record =  @grouped_records[client_code][transaction_type][company_symbol][rate]
          _record[:quantity] += quantity
          _record[:receivable_from_client] += client_dr
          @grouped_records[client_code][transaction_type][company_symbol][rate] = _record
        else
          _record = Hash.new
          _record[:quantity] = quantity
          _record[:receivable_from_client] = client_dr
          @grouped_records[client_code][transaction_type][company_symbol][rate] = _record
        end
      else
        _record = HashTree.new
        _record[rate][:quantity] = quantity
        _record[rate][:receivable_from_client] = client_dr
        @grouped_records[client_code][transaction_type][company_symbol] = _record
      end
    else
      client_single_record = HashTree.new
      client_single_record[transaction_type][company_symbol][rate][:quantity] = quantity
      client_single_record[transaction_type][company_symbol][rate][:receivable_from_client] = client_dr
      @grouped_records[client_code] = client_single_record
    end
  end
end