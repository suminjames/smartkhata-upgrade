class ChequeEntries::RejectionActivity < ChequeEntries::Activity
  def initialize(cheque_entry)
    super(cheque_entry)
    @is_associate_voucher_multi_chequed =  false
    @bills = []
    @particulars = []
    @settlements = []
  end

  def get_associated_bills

  end
end