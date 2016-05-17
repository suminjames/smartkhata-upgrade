class BillDecorator < ApplicationDecorator
  delegate_all
  decorates_association :share_transactions

  def formatted_bill_number
    object.fy_code.to_s + "-" + object.bill_number.to_s
  end

  def formatted_client_name
    client.name.titleize
  end

  def formatted_bill_dates
      bs_date = object.date_bs + ' BS'
      ad_date = object.date.to_s + ' AD'
      {"ad" => ad_date , "bs" => bs_date}
  end

  def formatted_transaction_dates
      bs_date = h.ad_to_bs(object.share_transactions[0].date).to_s + ' BS'
      ad_date =object.share_transactions[0].date.to_s + ' AD'
      {"ad" => ad_date , "bs" => bs_date}
  end

  #TODO Find a way to implement clearance_date. As of now, the viable option is to add 3 WORKING DAYS to transaction date. Verify if it is the most efficient way.
  def formatted_clearance_dates
    bs_date = 'TODO'
    ad_date = 'TODO'
      {"ad" => ad_date , "bs" => bs_date}
  end

  def formatted_client_phones
    phone_1 = client.phone.blank? ? 'N/A' : @client.phone
    phone_2 = client.phone_perm.blank? ? 'N/A' : @client.phone_perm
    {"primary" => phone_1, "secondary" => phone_2}
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

  # OPTIMIZE Is the bill transaction date the same as one of its share_transactions?
  def formatted_bill_message
    case type
    when 'pay'
      bill_type_verb = "Sold"
    when 'receive'
      bill_type_verb = "Purchashed"
    else
      bill_type_verb = ""
    end
    "As per your order dated " + formatted_transaction_dates['bs']+ ", we have " + bill_type_verb  + " these undernoted stocks."
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
    object.share_transactions.not_cancelled_for_bill.each do | share_transaction|
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
    object.share_transactions.not_cancelled_for_bill.each do | share_transaction|
      unique_isins.add(share_transaction.isin_info)
    end
    isin_abbreviation_index_str = ''
    unique_isins.each do |isin|
      isin_abbreviation_index_str += isin.isin + ': ' + isin.company + ' | '
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
end
