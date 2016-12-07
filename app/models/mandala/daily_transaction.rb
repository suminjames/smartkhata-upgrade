class Mandala::DailyTransaction < ActiveRecord::Base
  self.table_name = "daily_transaction"

  def bill_detail(bill_no = nil)
    if bill_no
      bill_details = Mandala::BillDetail.where(transaction_no: transaction_no, transaction_type: transaction_type, bill_no: bill_no)
    else
      bill_details = Mandala::BillDetail.where(transaction_no: transaction_no, transaction_type: transaction_type)
    end

    if bill_details.size != 1
      raise NotImplementedError
    end
    bill_details.first
  end

  def new_smartkhata_share_transaction(bill_no = nil)
    ::ShareTransaction.new({
        contract_no: transaction_no,
        quantity: final_quantity,
        raw_quantity: quantity,
        share_rate: rate,
        share_amount: total_amount,
        commission_rate: commission_rate(bill_no),
        commission_amount: commission_amount(bill_no),
        buyer: buyer,
        seller: seller,
        isin_info_id: isin_info_id,
        client_account_id: get_client_account_id,
        date: Date.parse(transaction_date),
        settlement_date: Date.parse(settlement_date),
        sebo: total_amount.to_f * 0.00015   ,
        cgt: bill_detail(bill_no).capital_gain.to_f,
        dp_fee: bill_detail(bill_no).demat_rate.to_f,
        adjusted_sell_price: adjusted_purchase_price,
        closeout_amount: closeout_amount,
        transaction_type: sk_transaction_type,
                           })
  end

  def isin_info_id
    isin_info = Mandala::CompanyParameter.where(company_code: company_code).first
    isin_info.present? ? isin_info.get_isin_info_id : nil
  end
  # close out consideration
  def final_quantity
    self.quantity
  end

  def total_amount
    self.quantity.to_f * self.rate.to_f
  end

  def commission_rate(bill_no)
    self.bill_detail(bill_no).commission_rate
  end

  def commission_amount(bill_no)
    self.bill_detail(bill_no).commission_amount
  end

  def sk_transaction_type
    self.transaction_type == 'P' ? ::ShareTransaction.transaction_types[:purchase] : ::ShareTransaction.transaction_types[:sales]
  end

  def customer_code_from_data
    self.transaction_type == 'P' ? customer_code : seller_customer_code
  end
  def buyer
    if self.transaction_type == 'P'
      self_broker_no
    else
      broker_no
    end

  end
  def seller
    if self.transaction_type == 'S'
      self_broker_no
    else
      broker_no
    end
  end

  def get_client_account_id
    begin
    Mandala::CustomerRegistration.where(customer_code: customer_code_from_data).first.find_or_create_smartkhata_client_account.id
    rescue
       p 'rescued'
    end
  end
end