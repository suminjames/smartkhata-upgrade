class CreateBankPaymentLetterService
  include ApplicationHelper
  attr_accessor :error_message

  def initialize(params)
    @nepse_settlement = params[:nepse_settlement]
    @bank_payment_letter = params[:bank_payment_letter]
    @current_user = params[:current_user]
    @branch_id = params[:branch_id]
    @fy_code = params[:fy_code]
    bill_ids = params[:bill_ids]
    @bills = Bill.where(id: bill_ids)
    @error_message = 'There was an error'
    @date = params[:date] || Time.now
  end

  def process
    fy_code = get_fy_code

    payment_bank_account = @bank_payment_letter.bank_account

    # bank payment letter cant be created without bills and payment bank account
    if @bills.empty?
      @error_message = "Bill List is empty"
      return false
    elsif payment_bank_account.nil?
      @error_message = "No Bank Account is selected"
      return false
    end

    # dont allow for this feature from all branch
    if @branch_id.zero? || @fy_code.nil?
      @error_message = "Invalid Operation, Please select correct fiscal year and branch"
      return false
    end

    bank_ledger = payment_bank_account.ledger
    description = "Settlement by bank payment"
    particulars = []
    net_paid_amount = 0.00
    ActiveRecord::Base.transaction do
      voucher = Voucher.create!(date: @date, branch_id: @branch_id, current_user_id: @current_user.id)
      voucher.desc = description
      voucher.pending!
      voucher.save!
      @bills.each do |bill|
        client_account = bill.client_account
        client_ledger = client_account.ledger
        ledger_balance = client_ledger.closing_balance(@fy_code)
        bill_amount = bill.balance_to_pay
        # dont pay the client more than he deserves.
        # pay only if the ledger balance is negative
        # for now we are not dealing with the positive amount
        next if ledger_balance + margin_of_error_amount >= 0

        # when the ledger amount is greater or equal to bill
        amount_to_settle = if (ledger_balance.abs - bill_amount) + margin_of_error_amount >= 0
                             bill_amount
                           else
                             ledger_balance.abs
                           end

        voucher.bills_on_creation << bill
        _description = "Settlement by bank payment for Bill: #{bill.full_bill_number}"
        particular = Particular.create!(transaction_type: :dr, ledger_id: client_ledger.id, name: _description, voucher_id: voucher.id, amount: amount_to_settle, transaction_date: Time.now, particular_status: :pending, branch_id: client_account.branch_id, current_user_id: @current_user.id, fy_code: @fy_code)

        particulars << particular
        net_paid_amount += amount_to_settle

        # mark the bills as settled
        bill.balance_to_pay = 0
        bill.status = Bill.statuses[:settled]
        bill.settlement_approval_status = :pending_approval
        bill.save!
      end
      Particular.create!(transaction_type: :cr, ledger_id: bank_ledger.id, name: description, voucher_id: voucher.id, amount: net_paid_amount, transaction_date: Time.now, particular_status: :pending, branch_id: @branch_id, current_user_id: @current_user.id, fy_code: @fy_code)
      @bank_payment_letter.voucher = voucher
    end

    [particulars, net_paid_amount, @bank_payment_letter]
  end

  def group_transaction_by_client(share_transactions); end
end
