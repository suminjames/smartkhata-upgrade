class ChequeEntries::RejectionActivity < ChequeEntries::Activity
  def initialize(cheque_entry, current_tenant_full_name, selected_branch_id = nil, selected_fy_code = nil)
    super(cheque_entry, current_tenant_full_name, selected_branch_id, selected_fy_code)
    @is_associate_voucher_multi_chequed =  false
    @bills = []
    @particulars = []
    @settlements = []
  end

  def get_associated_bills

  end
end