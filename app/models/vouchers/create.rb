class Vouchers::Create < Vouchers::Base
  attr_reader :settlement, :voucher, :ledger_list_financial, :ledger_list_available, :vendor_account_list, :client_ledger_list, :voucher_settlement_type, :group_leader_ledger_id, :vendor_account_id

  def initialize(attrs = {})
    super(attrs)
    @voucher = attrs[:voucher]
    @ledger_list_financial = []
    @ledger_list_available = nil
    @vendor_account_list = []
    @voucher_settlement_type = attrs[:voucher_settlement_type]
    @group_leader_ledger_id = attrs[:group_leader_ledger_id]
    @vendor_account_id = attrs[:vendor_account_id]
    # @current_tenant_full_name = attrs[:tenant_full_name]
  end

  def process
    # to track if the voucher can be saved.
    # result as false
    res = false

    # amount_entered = voucher.particulars.dr.sum(:amount)

    # get a calculated values, these are returned nil if not applicable
    @client_account, @bill, @bills, @amount_to_pay_receive, @voucher_type, settlement_by_clearance, bill_ledger_adjustment =
        set_bill_client(@client_account_id, @bill_ids, @bill_id, @voucher_type, @clear_ledger)
    # set the voucher type
    @voucher.voucher_type = @voucher_type

    # needed for error case
    if @voucher.receipt? || @voucher.payment?
      @ledger_list_financial = BankAccount.by_branch_id.all.uniq.collect(&:ledger)
      cash_ledger = Ledger.find_by(name: "Cash")
      @ledger_list_financial << cash_ledger
      # @ledger_list_available = Ledger.non_bank_ledgers
    end

    # assign all ledgers if ledger_list_available is not present
    @ledger_list_available ||= Ledger.all
    @vendor_account_list = VendorAccount.all
    @client_ledger_list = Ledger.find_all_client_ledgers

    is_payment_receipt = is_payment_receipt?(@voucher_type)


    vendor_account = nil
    if @voucher_settlement_type == 'vendor'
      vendor_account = VendorAccount.find_by(id: @vendor_account_id )
    elsif @voucher_settlement_type == 'client'
      client_group_leader_ledger = Ledger.find_by(id: @group_leader_ledger_id)
      client_group_leader_account = client_group_leader_ledger.client_account if client_group_leader_ledger.present?
    end

    # convert the bs date to english date for storage
    begin
      date_ad =bs_to_ad(@voucher.date_bs)
    rescue
      @error_message = "Invalid Date!"
      return
    end

    @voucher.date = date_ad
    @voucher.fy_code = get_fy_code(date_ad)
    # check if the user entered date is valid for that fiscal year
    unless date_valid_for_fy_code( @voucher.date , UserSession.selected_fy_code)
      @error_message = "Invalid Date for fiscal year!"
      return
    end


    # do not create voucher if bills have pending deal cancel
    bills_have_pending_deal_cancel, bill_number_with_deal_cancel = bills_have_pending_deal_cancel(@bills)
    if bills_have_pending_deal_cancel
      @error_message = "Bill with bill number #{bill_number_with_deal_cancel} has pending deal cancel"
      return
    end

    # make sure the group leader and vendor are selected where required.
    if @voucher_settlement_type == 'vendor' && vendor_account.nil?
      @error_message = "Please Select a vendor"
      return
    elsif @voucher_settlement_type == 'client' && client_group_leader_account.nil?
      @error_message = "Please Select a Client Ledger as a Group Head"
      return
    end


    if @voucher.particulars.length > 1
      @voucher, has_error, error_message, net_blnc, net_usable_blnc = process_particulars(@voucher, @voucher_settlement_type)
      @processed_bills = []
      # make changes in ledger balances and save the voucher
      if net_blnc == 0 && has_error == false
        @processed_bills, description_bills, receipt_amount = process_bills(is_payment_receipt, @client_account, net_blnc, net_usable_blnc, @clear_ledger, @voucher_type, @bills, bill_ledger_adjustment)
        @voucher, res, @error_message = voucher_save(@processed_bills, @voucher, description_bills, is_payment_receipt, @client_account, receipt_amount, @voucher_settlement_type, vendor_account, client_group_leader_account)
      else
        if has_error
          @error_message = error_message
        else
          @error_message = "Particulars should have balancing figures."
        end
      end
    else
      @error_message = is_payment_receipt ? "Please include atleast 1 particular" : "Particulars should be atleast 2"
    end
    res
  end

  def process_particulars(voucher, voucher_settlement_type)
    has_error = false
    error_message = ""
    net_blnc = 0
    net_usable_blnc = 0
    debit_ledgers = Hash.new 0
    credit_ledgers = Hash.new 0
    # check if debit equal credit or amount is not zero
    voucher.particulars.each do |particular|
      particular.description = voucher.desc
      particular.amount = particular.amount || 0
      if particular.amount <= 0
        has_error = true
        error_message ="Amount can not be negative or zero."
        break
      elsif particular.ledger_id.nil?
        has_error = true
        error_message ="Particulars cant be empty"
        break
      end

      (particular.dr?) ? net_blnc += particular.amount : net_blnc -= particular.amount

      # get a net usable balance to charge the client for billing purpose
      if voucher.receipt?
        net_usable_blnc += (particular.dr?) ? particular.amount : 0
      elsif voucher.payment?
        net_usable_blnc += (particular.cr?) ? particular.amount : 0
      end

      if (particular.cheque_number.present?)
        particular.ledger_type = Particular.ledger_types[:has_bank]
        if particular.cr?
          particular.additional_bank_id = nil
          voucher.is_payment_bank = true
          # Company can create payment by cheque for only one at a time
          # unless they are paying to a group or vendor
          if voucher.particulars.length > 2 && voucher_settlement_type == 'default'
            has_error = true
            error_message ="Single Cheque Entry only possible for payment by cheque"
            break
          end
        end
      end
    end
    return voucher, has_error, error_message, net_blnc, net_usable_blnc, debit_ledgers, credit_ledgers
  end

  def is_payment_receipt?(voucher_type)
    is_payment_receipt = false
    # ledgers need to be pre populated for sales and purchase type
    case voucher_type
      when Voucher.voucher_types[:receipt], Voucher.voucher_types[:payment]
        is_payment_receipt = true
    end
    is_payment_receipt
  end

  def process_bills(is_payment_receipt, client_account, net_blnc, net_usable_blnc, clear_ledger, voucher_type, bills, bill_ledger_adjustment)
    processed_bills = []
    description_bills = ""
    receipt_amount = net_usable_blnc.abs || 0.0


    if is_payment_receipt && client_account
      net_usable_blnc = (net_usable_blnc.abs + bill_ledger_adjustment)
      bills.each do |bill|

        # modify the net usable balance in case of the ledger clearout
        if clear_ledger
          # sales voucher => purchase of shares ( Broker sells to client)
          if voucher_type == Voucher.voucher_types[:receipt]
            if bill.sales?
              net_usable_blnc += (bill.balance_to_pay * 2.00)
            end
          else
            if bill.purchase?
              net_usable_blnc += (bill.balance_to_pay * 2.00)
            end
          end
        end

        # since the data is stored to 4 digits and payment is only applicable in 2 digits
        # round the balance_to_pay to 2 digits

        if bill.balance_to_pay.round(2) <= net_usable_blnc || (bill.balance_to_pay.round(2) - net_usable_blnc).abs <= @amount_margin_error
          net_usable_blnc = net_usable_blnc - bill.balance_to_pay
          description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number}   Amount: #{arabic_number(bill.balance_to_pay)}   Date: #{bill.date_bs} | "
          bill.balance_to_pay = 0
          bill.status = Bill.statuses[:settled]
          processed_bills << bill
        else
          bill.status = Bill.statuses[:partial]
          description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number}   Amount: #{arabic_number(net_blnc)}   Date: #{bill.date_bs} | "
          bill.balance_to_pay = bill.balance_to_pay - net_usable_blnc
          processed_bills << bill
          break
        end
      end

      # remove the last | sign
      description_bills = description_bills.slice(0, description_bills.length-2)
    end
    return processed_bills, description_bills, receipt_amount
  end

  def voucher_save(processed_bills, voucher, description_bills, is_payment_receipt, client_account, receipt_amount, voucher_settlement_type, vendor_account, client_group_leader_account)
    error_message = nil
    res = false
    settlement = nil
    settlements = []

    Voucher.transaction do
      # @receipt = nil
      # Processed_bills are the bills that are in the scope of this voucher.
      processed_bills.each(&:save)
      # bills that were created earlier and are about to get settled through this voucher.
      voucher.bills_on_settlement << processed_bills

      # changing this might need a change in the way description is being parsed to show the bill number in payment voucher
      # voucher.desc = !description_bills.blank? ? description_bills : voucher.desc

      # # create settlement in case of payment and receipt
      # if is_payment_receipt && !processed_bills.blank?
      #   settlement_type = Settlement.settlement_types[:payment]
      #   settlement_type = Settlement.settlement_types[:receipt] if voucher.voucher_type == Voucher.voucher_types[:receipt]
      #   settlement = Settlement.create(name: client_account.name, amount: receipt_amount, description: description_bills, date_bs: voucher.date_bs, settlement_type: settlement_type)
      # end

      voucher.particulars.each do |particular|
        particular.transaction_date = voucher.date
        particular.date_bs = voucher.date_bs
        # particular should be shown only when final(after being approved) in case of payment.
        particular.pending!

        ledger = Ledger.find(particular.ledger_id)
        # if client account is present which is true for the case where a single settlment is desired
        #  one customer pays on the behalf of his related ones
        # in default case create settlement for only the client account that is shown in particulars.
        the_client_account =  client_account ? client_account : ledger.client_account

        # particular.bill_id = bill_id
        if (particular.cheque_number.present?)
          # make the additional_bank_id nil for payment
          bank_account = ledger.bank_account

          client_account_id = nil
          vendor_account_id = nil
          cheque_name = nil
          if voucher_settlement_type == 'client'
            client_account_id = client_group_leader_account.id
            cheque_name = client_group_leader_account.name
          elsif voucher_settlement_type == 'vendor'
            vendor_account_id = vendor_account.id
            cheque_name = vendor_account.name
          end

          client_account_id ||= the_client_account.id if the_client_account.present?
          # cheque_name ||= @current_tenant_full_name

          begin
            # cheque entry recording
            #   cheque is payment if issued from the company
            #   cheque is receipt type if issued from the client
            cheque_entry = ChequeEntry.find_or_create_by!(cheque_number: particular.cheque_number, bank_account_id: bank_account.id, additional_bank_id: particular.additional_bank_id)
            cheque_entry.cheque_date = DateTime.now

            # if the cheque received from client is already entered to system reject it
            if cheque_entry.additional_bank_id.present? && !cheque_entry.unassigned?
              voucher.settlements = []
              error_message = "Cheque number is already taken"
              raise ActiveRecord::Rollback
            end

            # If cheque_entry is printed, reject the new voucher creation (with the cheque entry)
            if cheque_entry.printed?
              voucher.settlements = []
              error_message = "Cheque number provided is already taken. Therefore, a new cheque number has automatically been assigned."
              raise ActiveRecord::Rollback
            end

            if particular.additional_bank_id.present?
              cheque_entry.status = ChequeEntry.statuses[:pending_clearance]
            else
              cheque_entry.status = ChequeEntry.statuses[:pending_approval]
            end
            cheque_entry.beneficiary_name = cheque_name
            cheque_entry.client_account_id = client_account_id
            cheque_entry.vendor_account_id = vendor_account_id
            cheque_entry.amount = particular.amount
            cheque_entry.cheque_issued_type = ChequeEntry.cheque_issued_types[:receipt] if particular.dr?

            cheque_entry.save!
            # voucher.cheque_entries << cheque_entry
            if particular.additional_bank_id.nil?
              particular.cheque_entries_on_payment << cheque_entry
            else
              particular.cheque_entries_on_payment << cheque_entry
            end

          rescue ActiveRecord::RecordInvalid
            # TODO(subas) not sure if this is required
            voucher.settlements = []
            error_message = "Cheque Number is invalid"
            raise ActiveRecord::Rollback
          end

        end

        if is_payment_receipt && voucher_settlement_type == 'default'
          settlement = purchase_sales_settlement(voucher, ledger: ledger, particular: particular, client_account: the_client_account, description_bills: description_bills)
          # TODO()
          # voucher.settlements << settlement if settlement.present?
          # particular.settlements << settlement if settlement.present?
          # TODO(sarojk): Verify if settlement is created for payment and credit
          if voucher.payment?
            particular.debit_settlements << settlement if settlement.present?
          else
            particular.credit_settlements << settlement if settlement.present?
          end
          settlements << settlement if settlement.present?
        end

        # In case of payment by bank, it has to be approved.  For others, make final entry to the db.
        # It affects balances, etc.
        unless voucher.is_payment_bank
          # ledger.lock!
          # # closing_balance = ledger.closing_balance
          # # ledger.closing_balance = (particular.dr?) ? closing_balance + particular.amount : closing_balance - particular.amount
          # # particular.opening_balance = closing_balance
          # # particular.running_blnc = ledger.closing_balance
          # particular.complete!
          # ledger.save!
          Ledgers::ParticularEntry.new.insert_particular(particular)
        end
      end

      # if voucher settlement type is other than default create only a single settlement.
      if is_payment_receipt && voucher_settlement_type != 'default'
        if voucher_settlement_type == 'client'
          voucher.beneficiary_name = client_group_leader_account.name
        else
          voucher.beneficiary_name = vendor_account.name
        end

        settlement = purchase_sales_settlement(
            voucher,
            description_bills: description_bills,
            is_single_settlement: true,
            client_group_leader_account: client_group_leader_account,
            vendor_account: vendor_account,
            receipt_amount: receipt_amount
        )
        voucher.particulars.dr.each do |p|
          p.debit_settlements << settlement
        end
        voucher.particulars.cr.each do |p|
          p.credit_settlements << settlement
        end
      elsif is_payment_receipt
        if voucher.payment?
          voucher.particulars.cr.each do |p|
            p.credit_settlements << settlements
          end
        else
          voucher.particulars.dr.each do |p|
            p.debit_settlements << settlements
          end
        end
      end

      # mark the voucher as settled if it is not payment bank
      voucher.complete! unless voucher.is_payment_bank
      res = true if voucher.save
    end
    return voucher, res, error_message
  end

  def purchase_sales_settlement(voucher, attrs = {})
    ledger = attrs[:ledger]
    client_account = attrs[:client_account]
    settlement_description = attrs[:settlement_description]
    particular = attrs[:particular]
    is_single_settlement = attrs[:is_single_settlement] || false
    receipt_amount = attrs[:receipt_amount] || 0
    client_group_leader_account = attrs[:client_group_leader_account]
    vendor_account = attrs[:vendor_account]
    fy_code = attrs[:fy_code] ||= get_fy_code

    settler_name = ""
    settlement = nil
    settlement_description ||= voucher.desc

    # incase of multiple settlement or default take the amount from particular
    if !is_single_settlement
      if voucher.receipt?
        receipt_amount += (particular.cr?) ? particular.amount : 0
      elsif voucher.payment?
        receipt_amount += (particular.dr?) ? particular.amount : 0
      end
    end

    # in case of payment the settlement date has to be today itself as cheque is created on that day
    # in case of receipt however it can be voucher date
    if voucher.payment?
      settlement_date_bs = ad_to_bs(DateTime.now)
    else
      settlement_date_bs = voucher.date_bs
    end


    # single settlement for all the transaction exist only for the group leader and vendor accounting

    if is_single_settlement
      if client_group_leader_account.present?
        settler_name = client_group_leader_account.name
      else
        settler_name = vendor_account.name
      end
    elsif client_account.present?
      settler_name = client_account.name
    else
      settler_name = ledger.name
    end

    if is_single_settlement
      settlement_type = Settlement.settlement_types[:payment]
      settlement_type = Settlement.settlement_types[:receipt] if voucher.receipt?
      settlement = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: settlement_date_bs, settlement_type: settlement_type)
      settlement.client_account = client_group_leader_account
      settlement.vendor_account = vendor_account
    #   create settlement if the condition is satisfied because for a voucher we have both dr and cr particulars
    elsif voucher.receipt? && particular.cr? || voucher.payment? && particular.dr?
      settlement_type = Settlement.settlement_types[:payment]
      settlement_type = Settlement.settlement_types[:receipt] if voucher.receipt?
      client_account_id = client_account.id if client_account.present?
      settlement = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: settlement_date_bs, settlement_type: settlement_type, client_account_id: client_account_id)
      # settlement.client_account = client_account
    end

    settlement
  end
end