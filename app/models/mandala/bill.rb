class Mandala::Bill < ActiveRecord::Base
  self.table_name = "bill"

  def bill_details
    Mandala::BillDetail.joins('INNER JOIN bill  ON bill.bill_no = bill_detail.bill_no').where(bill_no: self.bill_no)
  end

end