class ChequeEntries::RejectionActivity < ChequeEntries::Activity
  def initialize(cheque_entry, current_tenant_full_name)
    super(cheque_entry, current_tenant_full_name)
    @is_associate_voucher_multi_chequed =  false
    @bills = []
    @particulars = []
    @settlements = []
  end

  def get_associated_bills

  end
end