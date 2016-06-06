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

      if @grouped_records.key?(client_code)
        if is_purchase == true
          if @grouped_records[client_code].key?[:buy]
          else
            client_single_record = HashTree.new
            client_single_record[:buy][symbol][rate][:quantity] = quantity
            client_single_record[:buy][symbol][rate][:receivable_from_client] = client_dr
            @grouped_records[client_code] = client_single_record
          end
        else
          if @grouped_records[client_code].key?[:sell]
          else
            client_single_record = HashTree.new
            client_single_record[:sell][symbol][rate][:quantity] = quantity
            client_single_record[:sell][symbol][rate][:receivable_from_client] = client_dr
            @grouped_records[client_code] = client_single_record
          end
        end

      else
        client_single_record = HashTree.new
        type = is_purchase == true ? :buy : :sell
        client_single_record[type][symbol][rate][:quantity] = quantity
        client_single_record[type][symbol][rate][:receivable_from_client] = client_dr
        @grouped_records[client_code] = client_single_record
      end

    end
  end
end