class BillDecorator < ApplicationDecorator
  delegate_all
  decorates_association :share_transactions

  # Group same isin (not deal cancelled) transaction with same share rate AND same commission rate AND same base price to be shown in single row in transaction listing.
  def formatted_group_same_isin_same_rate_transactions

    # Here, share_transactions_hash has both key and value pair as arrays.
    # hash signature excerpted from http://stackoverflow.com/questions/5009295/pushing-elements-onto-an-array-in-a-ruby-hash
    share_transactions_hash = Hash.new { |h, k| h[k]=[] }
    object.share_transactions.not_cancelled_for_bill.each do |share_transaction|
      share_transactions_hash[
          [
              share_transaction.isin_info.isin,
              share_transaction.share_rate,
              share_transaction.commission_rate,
              share_transaction.base_price
          ]
      ] << share_transaction
    end
    formatted_share_transactions = []
    share_transactions_hash.each do |st_array|

      transaction_row = Hash.new
      # Initialization of values which undergo mutation in the loop below
      transaction_row[:contract_no] = []
      transaction_row[:raw_quantity] = 0
      transaction_row[:raw_quantity_description] = '('
      transaction_row[:share_amount] = 0
      transaction_row[:commission_amount] = 0
      transaction_row[:capital_gain] = 0
      transaction_row[:is_ungrouped] = false

      # st_array[0] holds key; loop over st_array[1].
      st_array[1].each do |st|
        transaction_row[:contract_no] << st.contract_no.to_s
        transaction_row[:raw_quantity] += st.raw_quantity
        transaction_row[:raw_quantity_description] += st.raw_quantity.to_s + ', '
        transaction_row[:isin] = st.isin_info.isin
        transaction_row[:share_rate] = st.share_rate
        transaction_row[:base_price] = st.base_price
        transaction_row[:share_amount] += st.share_amount
        transaction_row[:commission_rate] = st.commission_rate
        transaction_row[:commission_amount] += st.commission_amount
        transaction_row[:capital_gain] += st.cgt
        transaction_row[:type] = st.transaction_type
        # For share_transactions which can't be grouped (and are therefore single), raw_quantity_description is unnecessary
        if st_array[1].count < 2
          transaction_row[:is_ungrouped] = true
          transaction_row[:raw_quantity_description] = ''
        end
      end

      # Relevant formatting of the values
      # Note: arabic_number() method returns a string with a decimal with 2 digits compulsorily. So strip where required. For example: share_rate and raw_quantity are never in decimal values.
      transaction_row[:contract_no] = get_concatenated_string_with_similarity(transaction_row[:contract_no])
      # transaction_row[:contract_no] = transaction_row[:contract_no][0...-2] # strip the trailing ', '
      transaction_row[:raw_quantity] = transaction_row[:raw_quantity]
      transaction_row[:raw_quantity_description] =  transaction_row[:raw_quantity_description][0...-2] + ')' if !transaction_row[:is_ungrouped] # strip the trailing ', ' and add trailing ')' as required
      transaction_row[:share_rate] = h.arabic_number(transaction_row[:share_rate])[0...-3]
      transaction_row[:base_price] = transaction_row[:type] =='selling' ? h.arabic_number(transaction_row[:base_price])[0...-3] : 'N/A'
      transaction_row[:share_amount] = h.arabic_number(transaction_row[:share_amount])[0...-3]
      transaction_row[:commission_rate] = transaction_row[:commission_rate] == "flat_25" ? "Flat NRs 25" : transaction_row[:commission_rate].to_f.to_s + "%"
      transaction_row[:commission_amount] = h.arabic_number(transaction_row[:commission_amount])
      transaction_row[:capital_gain] = h.arabic_number(transaction_row[:capital_gain])

      formatted_share_transactions << transaction_row
    end
    formatted_share_transactions
  end

  # For an array of strings, returns the length upto which all strings in the array are same.
  # Ex: Inputting ['tom', 'tommy', 'to1'] should return 2.
  def get_string_similarity_length(str_arr)
    return 0 if str_arr.length < 2
    similarity_count = 0
    match_ended = false
    ref_str = str_arr[0]
    (0..ref_str.length-1).each do |index|
      str_arr.each do |str|
        if ref_str[index] != str[index]
          match_ended = true
        end
        if match_ended
          break
        end
      end
      if !match_ended
        similarity_count += 1
      end
    end
    similarity_count
  end

  # Group same day same isin same price contract numbers.
  def get_concatenated_string_with_similarity(str_arr)
    return '' if str_arr.length == 0
    return str_arr[0] if str_arr.length == 1

    cutoff_index = get_string_similarity_length(str_arr) - 1
    concat_str = (str_arr[0])[0..cutoff_index] + '('
    str_arr.each do |str|
      concat_str += str[cutoff_index+1..-1].to_s + ', '
    end
    # strip comma ', ' at the end
    concat_str = concat_str[0..-3]
    concat_str += ')'
  end

  def formatted_bill_number
    object.fy_code.to_s + "-" + object.bill_number.to_s
  end

  def formatted_client_name
    client.name.titleize
  end

  def formatted_bill_dates
    bs_date = object.date_bs + ' BS'
    ad_date = object.date.to_s + ' AD'
    {"ad" => ad_date, "bs" => bs_date}
  end

  def formatted_transaction_dates
    bs_date = h.ad_to_bs_string(object.share_transactions[0].date).to_s + ' BS'
    ad_date =object.share_transactions[0].date.to_s + ' AD'
    {"ad" => ad_date, "bs" => bs_date}
  end

  def formatted_clearance_dates
    bs_date = h.ad_to_bs(object.settlement_date).to_s + ' BS'
    ad_date = object.settlement_date.to_s + ' AD'
    {"ad" => ad_date, "bs" => bs_date}
  end

  def formatted_client_phones
    phone_1 = client.phone.blank? ? 'N/A' : client.phone
    phone_2 = client.phone_perm.blank? ? 'N/A' : client.phone_perm
    phone_3 = client.mobile_number.blank? ? 'N/A' : client.mobile_number
    {"primary" => phone_1, "secondary" => phone_2, "mobile" => phone_3}
  end

  def formatted_client_phones_first_row
    "#{formatted_client_phones['mobile']}"
  end

  def formatted_client_phones_second_row
    arr = [formatted_client_phones['primary'],formatted_client_phones['secondary'] ]
    str = arr.select{|e| e != 'N/A'}.join ", "
    str = 'N/A' if str.empty?
    str
  end

  def formatted_client_all_phones
    arr = []
    formatted_client_phones.each do |key, value|
      arr << value
    end
    str = arr.select{|e| e != 'N/A'}.join ", "
    str = 'N/A' if str.empty?
    str
  end


  def formatted_net_bill_amount
    h.arabic_number(object.net_amount)
  end

  def formatted_net_receivable_amount
    object.purchase? ? h.arabic_number(object.net_amount) : 0.00
  end

  def formatted_net_payable_amount
    object.sales? ? h.arabic_number(object.net_amount) : 0.00
  end

  def formatted_net_closeout_amount
    object.sales? ? h.arabic_number(object.closeout_charge) : 0.00
  end



  def formatted_bill_age
    age_in_days = object.age
    case age_in_days
      when 0..6 then "#{age_in_days} days"
      when 7..29 then "> #{age_in_days/7} weeks"
      when 30..364 then "> #{age_in_days/30} months"
      else "> 1 year"
    end
  end

  # OPTIMIZE Is the bill transaction date the same as one of its share_transactions?
  def formatted_bill_message
    case type
      when 'sales'
        bill_type_verb = "Sold"
      when 'purchase'
        bill_type_verb = "Purchased"
      else
        bill_type_verb = ""
    end
    "As per your order dated " + formatted_transaction_dates['bs']+ ", we have " + bill_type_verb + " these undernoted stocks."
  end

  def client
    object.get_client
  end

  def type
    object.bill_type
  end

  def status
    object.status
  end

  def formatted_type
    object.bill_type.titleize
  end

  def formatted_status
    status.titleize
  end

  def formatted_companies_list
    # The `companies` hash maps an ISIN to its number of occurences
    companies = Hash.new(0);
    object.share_transactions.not_cancelled_for_bill.each do |share_transaction|
      companies[share_transaction.isin_info.isin.to_s] +=1
    end
    company_count_str = ''
    companies.each do |key, value|
      company_count_str += key + "(" + value.to_s + ")" + " "
    end
    company_count_str
  end

  def formatted_isin_abbreviation_index
    unique_isins = Set.new()
    object.share_transactions.not_cancelled_for_bill.each do |share_transaction|
      unique_isins.add(share_transaction.isin_info)
    end
    isin_abbreviation_index_str = ''
    unique_isins.each do |isin|
      isin_abbreviation_index_str += "#{isin.isin}: #{isin.company} | "
    end
    # strip the trailing '| ' and return
    isin_abbreviation_index_str.slice(0, isin_abbreviation_index_str.length-2)
  end

  def formatted_net_share_amount
    h.arabic_number(object.get_net_share_amount)
  end

  def formatted_net_sebo_commission
    h.arabic_number(object.get_net_sebo_commission)
  end

  def formatted_net_commission
    h.arabic_number(object.get_net_commission)
  end

  def formatted_net_dp_fee
    h.arabic_number(object.get_net_dp_fee)
  end

  def formatted_net_cgt
    h.arabic_number(object.get_net_cgt)
  end

  def formatted_fy_code
    # object.fy_code has a signature like '7273'
    # will return '72-73'
    object.fy_code.to_s.insert(2, '-')
  end

  # Determines whether or not an entity is to be hidden or not in the view.
  # returns - a css class identifier
  # Note:
  # - Following entities to be displayed in sales bills but not in purchase bills
  # -- base price
  # -- capital gain
  # -- net payable amount
  # - Following entities to be displayed in purchase bills but not in sales bills
  # -- net receivable amount
  def formatted_visibility_class(entity)
    sales_entities = ['base_price', 'capital_gain', 'net_payable_amount']
    purchase_entities = ['net_receivable_amount']

    is_relevant = true

    if object.sales?
      is_relevant = sales_entities.include? entity
    end
    if object.purchase?
      is_relevant = purchase_entities.include? entity
    end

    is_relevant == false ? 'no-display' : ''

  end

end
