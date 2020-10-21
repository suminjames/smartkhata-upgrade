module BillModule
  def get_bills_from_ids(bill_ids)
    Bill.where(id: bill_ids)
  end
end
