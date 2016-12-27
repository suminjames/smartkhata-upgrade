class Mandala::DailyTransaction < ActiveRecord::Base
  # include CommissionModule
  self.table_name = "daily_transaction"

  belongs_to :share_transaction

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

  def dp_fee

    if self.transaction_type == 'P'
      daily_transactions = Mandala::DailyTransaction.where(:customer_code => customer_code_from_data, :transaction_date => transaction_date, :transaction_type => transaction_type, :company_code => company_code)
    else
      daily_transactions = Mandala::DailyTransaction.where(:seller_customer_code => customer_code_from_data, :transaction_date => transaction_date, :transaction_type => transaction_type, :company_code => company_code)
    end
    if daily_transactions.size == 0
      raise NotImplementedError
    else
      dp_fee = 25.0 / daily_transactions.size
    end
    return dp_fee
  end

  # Missing share transactions(and their corresponding bills) can occur for days whose payout report haven't been
  # uploaded. For instance. If the migration occured for data taken Friday evening, share transactions(and their
  # corresponding bills) for days Wednesday and Thursday will not be accounted for during the migration. This method
  # tries to create share transactions (in SmartKhata) out of daily transactions (in Mandala) of sales transactions uploaded in floorsheet, whose payout hasn't been uploaded yet (therefore, the bill hasn't created).
  def new_smartkhata_share_transaction_with_out_bill
    date_ad = Date.parse(transaction_date)
    ::ShareTransaction.new({
                               contract_no: transaction_no,
                               quantity: final_quantity,
                               raw_quantity: quantity,
                               share_rate: rate,
                               share_amount: total_amount,
                               commission_rate: get_commission_rate(total_amount, date_ad),
                               commission_amount: get_commission(total_amount, date_ad),
                               buyer: buyer,
                               seller: seller,
                               isin_info_id: isin_info_id,
                               client_account_id: get_client_account_id,
                               date: date_ad,
                               settlement_date: Date.parse(settlement_date),
                               sebo: total_amount.to_f * 0.00015   ,
                               cgt: 0,
                               dp_fee: dp_fee,
                               adjusted_sell_price: adjusted_purchase_price,
                               closeout_amount: closeout_amount,
                               transaction_type: sk_transaction_type,
                           })

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
    self.transaction_type == 'P' ? ::ShareTransaction.transaction_types[:buying] : ::ShareTransaction.transaction_types[:selling]
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