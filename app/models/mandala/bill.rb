class Mandala::Bill < ActiveRecord::Base
  include FiscalYearModule

  self.table_name = "bill"

  def bill_details
    Mandala::BillDetail.joins('INNER JOIN bill  ON bill.bill_no = bill_detail.bill_no').where(bill_no: self.bill_no)
  end

  def new_smartkhata_bill
    fy_code = get_fy_code_from_fiscal_year(fiscal_year)
    ::Bill.unscoped.new({
        fy_code: fy_code,
        bill_number: get_bill_no,
        client_name: get_client_name,
        net_amount: net_amount,
        balance_to_pay: amount_to_pay,
        bill_type: sk_bill_type,
        status: status,
        date: Date.parse(bill_date),
        date_bs: bill_bs_date,
        settlement_date: Date.parse(clearance_date),
        client_account_id: get_client_account_id })
  end

  def fy_code
    get_fy_code_from_fiscal_year(fiscal_year)
  end

  def get_bill_no
    bill_info = bill_no.split('-')
    if bill_info.size > 1
      return bill_info[1]
    else
      return bill_info[0]
    end
  end

  def get_client_name
    Mandala::CustomerRegistration.where(customer_code: customer_code).first.customer_name
  end

  def get_client_account_id
    Mandala::CustomerRegistration.where(customer_code: customer_code).first.client_account.id
  end

  def amount_to_pay
    self.settlement_tag == 'Y' ? 0.00 : net_amount
  end

  def net_amount
    self.net_rev_amt.present? ? self.net_rev_amt : self.net_pay_amt
  end

  def status
    settlement_tag == 'Y' ? ::Bill.statuses[:settled] : ::Bill.statuses[:pending]
  end


  def sk_bill_type
    bill_type == 'P' ? ::Bill.bill_types[:purchase] : ::Bill.bill_types[:sales]
  end
end