class Vouchers::Setup < Vouchers::Base

  def voucher_and_relevant
    voucher_setup(@voucher_type, @client_account_id, @bill_id, @clear_ledger)
  end

  def voucher_setup(voucher_type,client_account_id, bill_id, clear_ledger )
    is_purchase_sales = false
    default_ledger_id = nil


    client_account, bill, bills, amount, voucher_type = set_bill_client(client_account_id, bill_id, voucher_type, clear_ledger)
    voucher = get_new_voucher(voucher_type)

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

    return voucher, is_purchase_sales, ledger_list, default_ledger_id, voucher_type
  end
end