class Vouchers::Create < Vouchers::Base
  attr_reader :settlement, :voucher, :ledger_list_financial, :ledger_list_available, :vendor_account_list, :client_ledger_list, :voucher_settlement_type, :group_leader_ledger_id, :vendor_account_id, :settlements, :selected_fy_code, :selected_branch_id, :current_user, :current_user_id

  def initialize(attrs = {})
    super(attrs)
    @voucher = attrs[:voucher]
    @voucher.current_user_id = attrs[:current_user].id
    @ledger_list_financial = []
    @ledger_list_available = nil
    @vendor_account_list = []
    @voucher_settlement_type = attrs[:voucher_settlement_type]
    @group_leader_ledger_id = attrs[:group_leader_ledger_id]
    @vendor_account_id = attrs[:vendor_account_id]
    @settlements = []
    @selected_fy_code = attrs[:selected_fy_code]
    @selected_branch_id = attrs[:selected_branch_id]
    @current_user = attrs[:current_user]
    @current_user_id = attrs[:current_user].id
  end

  def process
    # to track if the voucher can be saved.
    # result as false
    res = false

    # set the voucher type
    # causes issues for the voucher types when clear ledger is called
    # without this is set as jvr
    @voucher.voucher_type = @voucher_type
    # needed for error case
    if @voucher.is_payment_receipt?
      bank_accounts_in_branch = BankAccount.by_branch_id(selected_branch_id)

      default_for_payment_bank_account_in_branch = bank_accounts_in_branch.where(:default_for_payment => true).first
      default_for_receipt_bank_account_in_branch = bank_accounts_in_branch.where(:default_for_receipt => true).first

      # Check for availability of default bank accounts for payment and receipt in the current branch.
      # If not available in the current branch, resort to using whichever is available from all available branches.
      ledger_list_financial = bank_accounts_in_branch.all.uniq.collect(&:ledger).compact
      default_bank_payment = default_for_payment_bank_account_in_branch.present? ? default_for_payment_bank_account_in_branch : BankAccount.where(:default_for_payment => true).first
      default_bank_receive = default_for_receipt_bank_account_in_branch.present? ? default_for_receipt_bank_account_in_branch : BankAccount.where(:default_for_receipt => true).first

      cash_ledger = Ledger.find_by(name: "Cash")

      # In case when a bank account in a branch has a ledger, but doesn't have either default_for_payment or
      # default_for_receipt flagged on, the logic above resorts to searching the defaults from all available branches.
      # For this purpose, ledgers of default_bank_payment and default_bank_receive are added to ledger_list_financial.
      ledger_list_financial << default_bank_payment.ledger if default_bank_payment
      ledger_list_financial << default_bank_receive.ledger if default_bank_receive

      ledger_list_financial << cash_ledger

      @ledger_list_financial = ledger_list_financial.uniq
    end

    @ledger_list_available = []
    @vendor_account_list = VendorAccount.all
    @client_ledger_list = []

    # TODO (Subas): Redundant with voucher.rb may be
    is_payment_receipt = is_payment_receipt?(@voucher_type)


    vendor_account = nil
    if @voucher_settlement_type == 'vendor'
      vendor_account = VendorAccount.find_by(id: @vendor_account_id )
    elsif @voucher_settlement_type == 'client'
      client_group_leader_ledger = Ledger.find_by(id: @group_leader_ledger_id)
      if client_group_leader_ledger.present?
        client_group_leader_account = client_group_leader_ledger.client_account
        @client_ledger_list <<  client_group_leader_ledger
      end
    end

    # convert the bs date to english date for storage
    begin
      date_ad =bs_to_ad(@voucher.date_bs)
    rescue
      @error_message = "Invalid Date!"
      return
    end

    # convert the bs date to english date for storage
    begin
      value_date_ad =bs_to_ad(@voucher.value_date_bs)
    rescue
      @error_message = "Invalid Date!"
      return
    end

    @voucher.date = date_ad
    @voucher.value_date = value_date_ad
    @voucher.fy_code = get_fy_code(date_ad)
    @voucher.branch_id = get_branch_id_from_session
    # check if the user entered date is valid for that fiscal year
    unless date_valid_for_fy_code( @voucher.date , selected_fy_code)
      @error_message = "Invalid Date for fiscal year!"
      return
    end

    if @voucher.value_date < @voucher.date
      @error_message = "Value date must be the greater date than the current date and/or should lie within the current fiscal year!"
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

    # do not create voucher if bills have pending deal cancel
    bills_have_pending_deal_cancel, bill_number_with_deal_cancel = bills_have_pending_deal_cancel(@bills)
    if bills_have_pending_deal_cancel
      @error_message = "Bill with bill number #{bill_number_with_deal_cancel} has pending deal cancel"
      return
    end
    if @voucher.particulars.length > 1
      # according to new logic the bill settlement is done through particular
      # bills are tied up to particulars
      # TODO(Subas) Move the association away from voucher to the particulars perhaps
      @voucher,
          has_error,
          error_message,
          net_blnc,
          net_usable_blnc,
          net_cash_amount = process_particulars(@voucher, @voucher_settlement_type)

      @processed_bills = []
      # make changes in ledger balances and save the voucher
      if net_blnc == 0 && has_error == false
        receipt_amount  = net_usable_blnc.abs || 0
        # @processed_bills, description_bills = process_bills(is_payment_receipt, @client_account, net_usable_blnc, @clear_ledger, @voucher_type, @bills, bill_ledger_adjustment)

        @processed_bills, description_bills = process_client_bills(voucher, is_payment_receipt, @voucher_type)

        @voucher, res, @error_message, @settlements = voucher_save(@processed_bills, @voucher, description_bills, is_payment_receipt, @client_account, receipt_amount, @voucher_settlement_type, vendor_account, client_group_leader_account, net_cash_amount)
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
    net_cash_amount = 0
    cash_ledger_id = Ledger.find_by(name: "Cash").id
    # save associated ledgers to be shown in select tag in view, upon redirect
    # looped before processing to avoid it being not updated due to abrupt exit in code
    # also attr_reader and can be set?
    voucher.particulars.each do |particular|
      if particular.ledger_id.present?
        ledger_list_available << particular.ledger
      end
    end

    unless valid_branch(voucher)
      has_error = true
      error_message ="Branch is not correct"
    end

    # check if debit equal credit or amount is not zero
    unless has_error
      voucher.particulars.each do |particular|
        # keep track of the cash amount needed to be shown on the settlement receipt
        if voucher.is_payment_receipt?
          net_cash_amount += particular.amount if particular.ledger_id == cash_ledger_id
        end

        particular.description = voucher.desc if particular.description.blank?
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
        # earlier net usable balance was passed from the function which wont be necesary now
        # as bill processing will be handled on the particular portion itself

        if voucher.is_receipt?
          net_usable_blnc += (particular.dr?) ? particular.amount : 0
        elsif voucher.is_payment?
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
    end
    return voucher, has_error, error_message, net_blnc, net_usable_blnc, net_cash_amount
  end
  def process_client_bills(voucher, is_payment_receipt, voucher_type)
    processed_bills = []
    description_bills = ""


    voucher.particulars.each do |particular|
      if particular.bills_selection.present? && !particular.bills_selection.blank?
        # get a calculated values, these are returned nil if not applicable
        bill_ids = particular.bills_selection.split(',').map(&:to_i)
        _clear_ledger = particular.clear_ledger || false

        # this step does validations too.
        # so that bills of others are not added
        # dont call clear ledger from this point
        # clear ledger should not be called from the new voucher section as it modifies voucher type

        _client_account, _bills =
            set_bill_client(particular.ledger.client_account_id, bill_ids, voucher_type)


        # get it from particulars
        _bill_ledger_adjustment = particular.ledger_balance_adjustment.to_f || 0


        # do not create voucher if bills have pending deal cancel
        bills_have_pending_deal_cancel, bill_number_with_deal_cancel = bills_have_pending_deal_cancel(_bills)
        if bills_have_pending_deal_cancel
          @error_message = "Bill with bill number #{bill_number_with_deal_cancel} has pending deal cancel"
          return
        end
        _processed_bills, _description_bills, _receipt_amount = process_bills(is_payment_receipt, _client_account, particular.amount, voucher.voucher_type, _bills, _bill_ledger_adjustment)

        processed_bills += _processed_bills
        description_bills += _description_bills
      end
    end
    return processed_bills, description_bills
  end
  def is_payment_receipt?(voucher_type)
    is_payment_receipt = false
    # ledgers need to be pre populated for sales and purchase type
    case voucher_type
    when Voucher.voucher_types[:receipt],
      Voucher.voucher_types[:payment],
      Voucher.voucher_types[:payment_cash],
      Voucher.voucher_types[:receipt_cash],
      Voucher.voucher_types[:receipt_bank],
      Voucher.voucher_types[:payment_bank],
      Voucher.voucher_types[:receipt_bank_deposit],
      Voucher.voucher_types[:receipt_esewa],
      Voucher.voucher_types[:receipt_nchl]
      is_payment_receipt = true
    end
    is_payment_receipt
  end

  def process_bills(is_payment_receipt, client_account, net_usable_blnc, voucher_type, bills, bill_ledger_adjustment)

    processed_bills = []
    description_bills = ""
    if is_payment_receipt && client_account

      # net usable balance is the particular amount for a client
      net_usable_blnc = (net_usable_blnc.abs + bill_ledger_adjustment)

      bills.each do |bill|
        # it considers the case when both the types of bills are selected
        # incase of receipt , we need to adjust the sales bill amount
        # by adding the amount twice, making sure that one is for reduction that is used in the function below
        # the other is the actual effect, ie we are adding it from our part (payment)
        if is_voucher_receipt?(voucher_type)
          if bill.sales?
            net_usable_blnc += (bill.balance_to_pay * 2.00)
          end
        else
          if bill.purchase?
            net_usable_blnc += (bill.balance_to_pay * 2.00)
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
          description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number}   Amount: #{arabic_number(net_usable_blnc)}   Date: #{bill.date_bs} | "
          bill.balance_to_pay = bill.balance_to_pay - net_usable_blnc
          processed_bills << bill
          break
        end
      end

      # remove the last | sign
      description_bills = description_bills.slice(0, description_bills.length-2)
    end
    return processed_bills, description_bills
  end

  def voucher_save(processed_bills, voucher, description_bills, is_payment_receipt, client_account, receipt_amount, voucher_settlement_type, vendor_account, client_group_leader_account, net_cash_amount)
    error_message = nil
    res = false
    settlement = nil
    settlements = []
    current_date = Date.today

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

      branch_id = selected_branch_id.to_i == 0 ? voucher.branch_id : selected_branch_id

      # flag to know if the voucher has cheque entry
      voucher_has_cheque_entry = false
      voucher.particulars.each do |particular|
        particular.transaction_date = voucher.date
        particular.date_bs = voucher.date_bs
        particular.value_date = voucher.value_date
        particular.creator_id ||= current_user&.id
        particular.updater_id = current_user&.id
        particular.branch_id ||= branch_id
        particular.current_user_id = current_user&.id

        # unless date_valid_for_fy_code(particular.value_date, selected_fy_code, current_date)
        #   error_message = "Value date must be the greater date than the current date and/or should lie within the current fiscal year!"
        #   raise ActiveRecord::Rollback
        # end
        # particular should be shown only when final(after being approved) in case of payment.
        particular.pending!

        ledger = Ledger.find(particular.ledger_id)
        # if client account is present which is true for the case where a single settlment is desired
        #  one customer pays on the behalf of his related ones
        # in default case create settlement for only the client account that is shown in particulars.
        the_client_account =  client_account ? client_account : ledger.client_account

        # particular.bill_id = bill_id
        if (particular.cheque_number.present?)

          # turn the flag for cheque on
          voucher_has_cheque_entry = true

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
            #
            #TODO major change to be rollback on future
            set_required_data = lambda { |l| l.branch_id =  particular.branch_id; l.current_user_id = @current_user_id }
            cheque_entry = ChequeEntry.find_or_create_by!(cheque_number: particular.cheque_number, bank_account_id: bank_account.id, additional_bank_id: particular.additional_bank_id, &set_required_data)
            if voucher.is_payment?
              cheque_entry.cheque_date = DateTime.now
            else
              cheque_entry.cheque_date = voucher.date
            end

            # For receipt cheques,
            # - if the cheque received from client is already entered to system, reject it
            # - however, if the cheque was bounced earlier, don't reject it.
            # if cheque_entry.additional_bank_id.present? && !(cheque_entry.unassigned? || cheque_entry.bounced?)
            if cheque_entry.additional_bank_id.present? && !cheque_entry.unassigned? && !cheque_entry.bounced?
              voucher.settlements = []
              error_message = "Cheque number is already taken. If reusing the cheque is really necessary, it must be bounced first."
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
          settlement = purchase_nepse_settlement(voucher, ledger: ledger, particular: particular, client_account: the_client_account, description_bills: description_bills, cash_amount: net_cash_amount)
          # TODO()
          # voucher.settlements << settlement if settlement.present?
          # particular.settlements << settlement if settlement.present?
          # TODO(sarojk): Verify if settlement is created for payment and credit
          if voucher.is_payment?
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
          Ledgers::ParticularEntry.new(@current_user_id).insert_particular(particular)
        end
      end
      # if voucher settlement type is other than default create only a single settlement.
      if is_payment_receipt && voucher_settlement_type != 'default'
        if voucher_settlement_type == 'client'
          voucher.beneficiary_name = client_group_leader_account.name
        else
          voucher.beneficiary_name = vendor_account.name
        end

        settlement = purchase_nepse_settlement(
            voucher,
            description_bills: description_bills,
            is_single_settlement: true,
            client_group_leader_account: client_group_leader_account,
            vendor_account: vendor_account,
            receipt_amount: receipt_amount,
            cash_amount: net_cash_amount
        )
        voucher.particulars.select{|x| x.dr?}.each do |p|
          p.debit_settlements << settlement
        end
        voucher.particulars.select{|x| x.cr?}.each do |p|
          p.credit_settlements << settlement
        end
        settlements << settlement
      elsif is_payment_receipt
        if voucher.is_payment?
          voucher.particulars.select{|x| x.cr?}.each do |p|
            p.credit_settlements << settlements
          end
        else
          voucher.particulars.select{|x| x.dr?}.each do |p|
            p.debit_settlements << settlements
          end
        end
      end

      # logic to make the voucher comply to new standard
      # splitting the payment and receipt to multiple types

      if !voucher.is_receipt_transaction?
        if is_payment_receipt && voucher_has_cheque_entry
          if voucher.is_payment?
            voucher.voucher_type = Voucher.voucher_types[:payment_bank]
          else
            voucher.voucher_type = Voucher.voucher_types[:receipt_bank]
          end
        elsif is_payment_receipt
          if voucher.is_payment?
            voucher.voucher_type = Voucher.voucher_types[:payment_cash]
          else
            voucher.voucher_type = Voucher.voucher_types[:receipt_cash]
          end
        end
      end
      # mark the voucher as settled if it is not payment bank
      voucher.creator_id ||= current_user&.id
      voucher.updater_id = current_user&.id
      voucher.complete! unless voucher.is_payment_bank
      res = true if voucher.save
    end
    return voucher, res, error_message, settlements
  end

  def purchase_nepse_settlement(voucher, attrs = {})
    ledger = attrs[:ledger]
    client_account = attrs[:client_account]
    settlement_description = attrs[:settlement_description]
    particular = attrs[:particular]
    is_single_settlement = attrs[:is_single_settlement] || false
    receipt_amount = attrs[:receipt_amount] || 0
    client_group_leader_account = attrs[:client_group_leader_account]
    vendor_account = attrs[:vendor_account]
    cash_amount = attrs[:cash_amount] || 0.0
    settlement = nil
    settlement_description ||= voucher.desc

    # incase of multiple settlement or default take the amount from particular
    if !is_single_settlement
      if voucher.is_receipt? || voucher.is_receipt_transaction?
        receipt_amount += (particular.cr?) ? particular.amount : 0
      elsif voucher.is_payment?
        receipt_amount += (particular.dr?) ? particular.amount : 0
      end
    end

    # in case of payment the settlement date has to be today itself as cheque is created on that day
    # in case of receipt however it can be voucher date
    if voucher.is_payment?
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
      settlement_type           = Settlement.settlement_types[:payment]
      settlement_type           = Settlement.settlement_types[:receipt] if voucher.is_receipt?
      settlement                = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: settlement_date_bs, settlement_type: settlement_type, cash_amount: cash_amount, branch_id: voucher.branch_id, fy_code: voucher.fy_code, current_user_id: current_user.id)
      settlement.client_account = client_group_leader_account
      settlement.vendor_account = vendor_account
      #   create settlement if the condition is satisfied because for a voucher we have both dr and cr particulars
    elsif voucher.is_receipt? && particular.cr? || voucher.is_payment? && particular.dr? || voucher.is_receipt_transaction? && particular.cr?
      settlement_type   = Settlement.settlement_types[:payment]
      settlement_type   = Settlement.settlement_types[:receipt] if voucher.is_receipt? || voucher.is_receipt_transaction?
      client_account_id = client_account.id if client_account.present?
      settlement        = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: settlement_date_bs, settlement_type: settlement_type, client_account_id: client_account_id, cash_amount: cash_amount, branch_id: voucher.branch_id, fy_code: voucher.fy_code, current_user_id: current_user.id)
      # settlement.client_account = client_account
    end
    settlement
  end

  def set_bill_client(client_account_id, bill_ids, voucher_type)
    # set default values to nil
    bill_ids ||= []
    bills = []

    # get client account and bill if present from respective ids
    client_account = client_account_and_bill(client_account_id)

    bill_list = get_bills_from_ids(bill_ids)

    related_pending_bill_ids = client_account.get_all_related_bill_ids
    # make sure all id in bill_ids are in related_pending_bill_ids
    unless (bill_ids - related_pending_bill_ids).empty?
      # this condition should not be true
      raise SmartKhataError
    end
    # arrange bills based on the voucher type
    bills_receive = bill_list.requiring_receive
    bills_payment = bill_list.requiring_payment

    if voucher_type == Voucher.voucher_types[:receipt]
      bills = [*bills_payment, *bills_receive]
    else
      bills = [*bills_receive, *bills_payment]
    end

    return client_account, bills
  end


  def get_branch_id_from_session
    selected_branch_id == 0 ? current_user.branch_id : selected_branch_id
  end

  def valid_branch(voucher)
    voucher.particulars.each do |particular|
      if particular.ledger_id.present?
        ledger = Ledger.find(particular.ledger_id)
        effective_branch = ledger.effective_branch
        if effective_branch && effective_branch != particular.branch_id
          return false
        end
      end
    end
    return true
  end

  def is_voucher_receipt?(voucher_type)
    [:receipt.to_s,:receipt_nchl.to_s,:receipt_esewa.to_s].include?(voucher_type)
  end
end
