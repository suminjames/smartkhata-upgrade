module BillModule
  def get_bills_from_ids(bill_ids)
    return Bill.where(id: bill_ids)
  end
end