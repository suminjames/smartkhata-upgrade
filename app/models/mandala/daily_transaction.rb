# == Schema Information
#
# Table name: daily_transaction
#
#  id                       :integer          not null, primary key
#  transaction_no           :string
#  job_no                   :string
#  share_code               :string
#  quantity                 :string
#  rate                     :string
#  customer_code            :string
#  broker_no                :string
#  broker_job_no            :string
#  self_broker_no           :string
#  transaction_date         :string
#  settlement_date          :string
#  transaction_type         :string
#  base_price               :string
#  transaction_bs_date      :string
#  settlement_bs_date       :string
#  company_code             :string
#  seller_customer_code     :string
#  buyer_bill_no            :string
#  seller_bill_no           :string
#  deposited_date           :string
#  receipt_date             :string
#  client_account_no        :string
#  cash_account_no          :string
#  remarks                  :string
#  cancel_tag               :string
#  chalan_no                :string
#  buyer_order_no           :string
#  seller_order_no          :string
#  broker_transaction       :string
#  other_broker_transaction :string
#  fiscal_year              :string
#  base_price_date          :string
#  transaction_status       :string
#  nepse_commission         :string
#  sebo_commission          :string
#  tds                      :string
#  capital_gain             :string
#  capital_gain_tax         :string
#  adjusted_purchase_price  :string
#  payout_tag               :string
#  closeout_quantity        :string
#  closeout_amount          :string
#  closeout_tag             :string
#  receivable_amount        :string
#  settlement_id            :string
#  voucher_no               :string
#  voucher_code             :string
#  closeout_voucher_tag     :string
#  closeout_voucher_no      :string
#  share_transaction_id     :integer
#

class Mandala::DailyTransaction < ActiveRecord::Base
  self.table_name = "daily_transaction"

  def bill_detail
    bill_details = Mandala::BillDetail.where(transaction_no: transaction_no, transaction_type: transaction_type)
    if bill_details.size != 1
      raise NotImplementedError
    end
    bill_details.first
  end

  def new_smartkhata_share_transaction
    ::ShareTransaction.new({
        contract_no: transaction_no,
        quantity: final_quantity,
        raw_quantity: quantity,
        share_rate: rate,
        share_amount: total_amount,
        commission_rate: commission_rate,
        commission_amount: commission_amount,
        buyer: buyer,
        seller: seller,
        isin_info_id: isin_info_id,
        client_account_id: get_client_account_id,
        date: Date.parse(transaction_date),
        settlement_date: Date.parse(settlement_date),
        sebo: total_amount.to_f * 0.00015   ,
        cgt: bill_detail.capital_gain.to_f,
        dp_fee: bill_detail.demat_rate.to_f,
        adjusted_sell_price: adjusted_purchase_price
                           })
  end

  def isin_info_id
    Mandala::CompanyParameter.where(company_code: company_code).first.get_isin_info_id
  end
  # close out consideration
  def final_quantity
    self.quantity
  end

  def total_amount
    self.quantity.to_f * self.rate.to_f
  end

  def commission_rate
    self.bill_detail.commission_rate
  end

  def commission_amount
    self.bill_detail.commission_amount
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
