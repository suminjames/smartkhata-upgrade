class Vouchers::Setup
  def initialize(client_account_id, bill_id, voucher_type)
    @client_account_id = client_account_id,
    @bill_id = bill_id,
    @voucher_type = voucher_type
  end

  def voucher_setup(client_account_id, bill_id, voucher_type)
    is_purchase_sales = false
    default_ledger_id = nil

    voucher = get_new_voucher(voucher_type)
    client_account,bill,bills,amount = set_bill_client(client_account_id, bill_id, voucher_type)

    if voucher_type == Voucher.voucher_types[:sales] || voucher_type == Voucher.voucher_types[:purchase]
      is_purchase_sales = true
      ledger_list = BankAccount.all.uniq.collect(&:ledger)
      default_bank_purchase = BankAccount.where(:default_for_purchase => true).first
      default_bank_sales = BankAccount.where(:default_for_sales   => true).first
      cash_ledger = Ledger.find_by(name: "Cash")
      ledger_list << cash_ledger

      if voucher_type == Voucher.voucher_types[:sales]
        default_ledger_id = default_bank_sales ? default_bank_sales.ledger.id : cash_ledger.id
        puts "this is one#{default_ledger_id}"
      else
        default_ledger_id = default_bank_purchase ? default_bank_purchase.ledger.id : cash_ledger.id
        puts "this is another#{default_ledger_id}"
      end
      voucher.desc = "Being settled for Bill No: #{bills.map{|a| "#{a.fy_code}-#{a.bill_number}"}.join(',')}" if bills.length > 0
    end


    voucher.particulars = []
    if is_purchase_sales
      transaction_type = voucher_type == Voucher.voucher_types[:sales] ? Particular.transaction_types[:dr] : Particular.transaction_types[:cr]
      voucher.particulars << Particular.new(ledger_id: default_ledger_id,amnt: amount, transaction_type: transaction_type)
    end

    # for sales and purchase we need two particular one for debit and one for credit
    voucher.particulars <<  Particular.new(ledger_id: client_account.ledger.id,amnt: amount) if client_account.present?
    # a general particular for the voucher
    voucher.particulars << Particular.new if client_account.nil?

    return voucher, is_purchase_sales, ledger_list, default_ledger_id
  end

  private

  def get_new_voucher(voucher_type)
    voucher = Voucher.new
    voucher.voucher_type = voucher_type
    voucher
  end

  def set_bill_client(client_account_id, bill_id, voucher_type)
    # set default values to nil
    client_account = nil
    bill = nil
    bills = []
    amount = 0.0

    # find the bills for the client
    if client_account_id.present?
      client_account = ClientAccount.find(client_account_id)
    elsif bill_id.present?
      bill = Bill.find(bill_id)
      client_account = bill.client_account
    else
      client_account = nil
      bill = nil
    end



    case voucher_type
      when Voucher.voucher_types[:sales]
        # check if the client account is present
        # and grab all the bills from which we can receive amount if bill is not present
        # else grab the amount to be paid from the bill
        if client_account.present?
          unless bill.present?
            bills = client_account.bills.requiring_receive

            # TODO how to make the below commented line work
            # amount = bills.sum(&:balance_to_pay)
            amount = bills.sum(:balance_to_pay)
          else
            bills = [bill]
            amount = bill.balance_to_pay
          end

          amount = amount.abs
        end

      when Voucher.voucher_types[:purchase]
        if client_account.present?
          unless bill.present?
            bills = client_account.bills.requiring_payment
            amount = bills.sum(:balance_to_pay)
          else
            bills = [bill]
            amount = bill.balance_to_pay
          end
          amount = amount.abs
        end
    end
    amount = amount.round(2)
    return client_account, bill, bills, amount
  end

end