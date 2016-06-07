class HashTree < Hash
  def initialize
    super do |hash, key|
      hash[key] = HashTree.new
    end
  end
end

class CreateSmsService
  include CustomDateModule

  def initialize(floorsheet_records, broker_code, transaction_date = Time.now)
    @floorsheet_records = floorsheet_records
    @grouped_records = Hash.new
    @broker_code = broker_code
    @transaction_date_short = ad_to_bs(transaction_date)[5..-1].sub('-','/')
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
      company_symbol = transaction_record[1]
      client_name = transaction_record[4]
      client_code = transaction_record[5]
      quantity = transaction_record[6]
      rate = transaction_record[7]
      client_dr = transaction_record[11]
      bill_id = transaction_record[16]
      is_purchase = transaction_record[17]
      transaction_date = transaction_record[18]

      transaction_type = is_purchase == true ? :buy : :sell
      if @grouped_records.key?(client_code)
        group_by_client_and_transaction_type(client_code,transaction_type, company_symbol, rate, quantity, client_dr, client_name, bill_id, transaction_date)
      else
        client_single_record = HashTree.new
        client_single_record[:data][transaction_type][company_symbol][rate][:quantity] = quantity
        client_single_record[:data][transaction_type][company_symbol][rate][:receivable_from_client] = client_dr
        client_single_record[:info][:name] = client_name
        client_single_record[:info][:bill_id] = bill_id
        @grouped_records[client_code] = client_single_record
      end
    end

    # @grouped_records.each do |key,value|
    #   client_code = key
    #   value.each do |k, v|
    #
    #   end
    # end

    processed_sms =iterate_grouped_transactions(@grouped_records)
    x = 1
  end

  def group_by_client_and_transaction_type(client_code,transaction_type, company_symbol, rate, quantity, client_dr, client_name, bill_id, transaction_date)
    if @grouped_records[client_code][:data].key? transaction_type
      if @grouped_records[client_code][:data][transaction_type].key? company_symbol
        if @grouped_records[client_code][:data][transaction_type][company_symbol].key? rate
          _record =  @grouped_records[client_code][:data][transaction_type][company_symbol][rate]
          _record[:quantity] += quantity
          _record[:receivable_from_client] += client_dr
          @grouped_records[client_code][:data][transaction_type][company_symbol][rate] = _record
        else
          _record = Hash.new
          _record[:quantity] = quantity
          _record[:receivable_from_client] = client_dr
          @grouped_records[client_code][:data][transaction_type][company_symbol][rate] = _record
        end
      else
        _record = HashTree.new
        _record[rate][:quantity] = quantity
        _record[rate][:receivable_from_client] = client_dr
        @grouped_records[client_code][:data][transaction_type][company_symbol] = _record
      end
    else
      client_single_record = HashTree.new
      client_single_record[:data][transaction_type][company_symbol][rate][:quantity] = quantity
      client_single_record[:data][transaction_type][company_symbol][rate][:receivable_from_client] = client_dr
      client_single_record[:info][:name] = client_name
      client_single_record[:info][:bill_id] = bill_id
      @grouped_records[client_code] = client_single_record
    end
  end

  def iterate_grouped_transactions(h)
    processed_sms = []
    # iterate by client_code
    # key => client_code v = data for the day
    h.each do |k,v|
      info = v[:info]
      client_name = info[:name].split.first.titleize
      transaction_data = v[:data]
      transaction_data.each do |type_of_transaction, data|
        str = ""
        total = 0.0
        data.each do |symbol, symbol_data|
          str += ";#{symbol} "
          symbol_data.each do |rate, rate_data|
            str += ",#{rate_data[:quantity].to_i}@#{rate}"
            total += rate_data[:receivable_from_client].to_f
          end
        end
        final_str = ""
        # hack used to remove ; from the beginning of symbol ;ccbl,1@23,2@33;nmmb,234@12
        str[0] = ""
        if type_of_transaction == :buy
          final_str = "#{client_name} bought #{str};On #{@transaction_date_short} Bill No#{info[:bill_id]} .Pay NRs#{total.round(2)}.BNo #{@broker_code}"
        else
          final_str += "#{client_name} sold #{str};On #{@transaction_date_short}.BNo #{@broker_code}"
        end


        processed_sms << final_str
      end
    end
    processed_sms
  end

  # TODO (SUBAS Remove when you feel confident)
  def iterate(h)
    h.each do |k,v|
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