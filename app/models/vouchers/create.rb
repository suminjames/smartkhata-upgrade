class Vouchers::Create < Vouchers::Base
  attr_reader :settlement, :voucher
  def initialize(attrs = {})
    super(attrs)
    @voucher = attrs[:voucher]
    @settlement = nil
  end

  def process
    # to track if the voucher can be saved.
    # result as false
    res = false

    # convert the bs date to english date for storage
    cal = NepaliCalendar::Calendar.new
    bs_string_arr =  @voucher.date_bs.to_s.split(/-/)
    @voucher.date = cal.bs_to_ad(bs_string_arr[0],bs_string_arr[1], bs_string_arr[2])


    # get a calculated values, these are returned nil if not applicable
    @client_account, @bill, @bills, @amount_to_pay_receive, @voucher_type =
        set_bill_client(@client_account_id, @bill_id, @voucher_type, @clear_ledger)
    # set the voucher type
    @voucher.voucher_type = @voucher_type
    is_purchase_sales = false


    # ledgers need to be pre populated for sales and purchase type
    case @voucher_type
      when Voucher.voucher_types[:sales],Voucher.voucher_types[:purchase]
        is_purchase_sales = true
    end

    has_error = false
    error_message = ""
    net_blnc = 0
    net_usable_blnc = 0
    receipt_amount = 0


    if @voucher.particulars.length > 1
      # check if debit equal credit or amount is not zero
      @voucher.particulars.each do |particular|



        particular.description = @voucher.desc
        particular.amnt = particular.amnt || 0
        if particular.amnt <= 0
          has_error = true
          error_message ="Amount can not be negative or zero."
          break
        elsif particular.ledger_id.nil?
          has_error = true
          error_message ="Particulars cant be empty"
          break
        end
        (particular.dr?) ? net_blnc += particular.amnt : net_blnc -= particular.amnt

        # get a net usable balance to charge the client for billing purpose
        if  @voucher_type == Voucher.voucher_types[:sales]
          net_usable_blnc += (particular.dr?) ? particular.amnt : 0
        elsif @voucher_type == Voucher.voucher_types[:purchase]
          net_usable_blnc += (particular.cr?) ? particular.amnt : 0
        end
        if (particular.cheque_number.present?)
          particular.has_bank!
          if particular.cr?
            particular.additional_bank_id = nil
            @voucher.is_payment_bank = true
            # Company can create payment by cheque for only one at a time
            if @voucher.particulars.length > 2
              has_error = true
              error_message ="Single Cheque Entry possible for payment by cheque"
              break
            end
          end
        end
      end

      # add the particular to the voucher for sales or purchase
      @processed_bills = []

      # # add the ledger name in case of 2 particulars
      # if @voucher.particulars.length == 2 && !has_error
      #   @voucher.particulars[0].name = Ledger.find(@voucher.particulars[1].ledger_id).name
      #   @voucher.particulars[1].name = Ledger.find(@voucher.particulars[0].ledger_id).name
      # end

      # make changes in ledger balances and save the voucher
      if net_blnc == 0 && has_error == false
        # capture  the bill number and amount billed to description billed
        description_bills = ""

        if is_purchase_sales && @client_account
          # transaction_type = net_blnc >= 0 ? Particular.transaction_types[:cr] : Particular.transaction_types[:dr]
          receipt_amount = net_usable_blnc.abs
          net_usable_blnc = net_usable_blnc.abs
          @bills.each do |bill|

            # modify the net usable balance in case of the ledger clearout
            if @clear_ledger
              # sales voucher => purchase of shares ( Broker sells to client)
              if  @voucher_type == Voucher.voucher_types[:sales]
                if  bill.sales?
                  net_usable_blnc +=  ( bill.balance_to_pay * 2.00)
                end
              else
                if  bill.purchase?
                  net_usable_blnc +=  ( bill.balance_to_pay * 2.00)
                end
              end
            end

            # since the data is stored to 4 digits and payment is only applicable in 2 digits
            # round the balance_to_pay to 2 digits

            if bill.balance_to_pay.round(2) <=  net_usable_blnc || ( bill.balance_to_pay.round(2) - net_usable_blnc).abs <= 0.01
              net_usable_blnc = net_usable_blnc - bill.balance_to_pay
              description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number} Amount: #{arabic_number(bill.balance_to_pay)} Date: #{ad_to_bs(bill.created_at)} | "
              bill.balance_to_pay = 0
              bill.status = Bill.statuses[:settled]
              @processed_bills << bill
            else
              bill.status = Bill.statuses[:partial]
              description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number} Amount: #{arabic_number(net_blnc)} Date: #{ad_to_bs(bill.created_at)} | "
              bill.balance_to_pay = bill.balance_to_pay - net_usable_blnc
              @processed_bills << bill
              break
            end

          end
        end

        Voucher.transaction do
          @receipt = nil
          @processed_bills.each(&:save)
          @voucher.bills_on_settlement << @processed_bills
          @voucher.desc = description_bills
          # TODO add the cheque tracking to receipt
          # TODO add bill tracking to receipt
          # TODO add number to receipt
          # TODO add client tracking

          if is_purchase_sales && !@processed_bills.blank?
            settlement_type = Settlement.settlement_types[:payment]
            settlement_type = Settlement.settlement_types[:receipt] if @voucher_type == Voucher.voucher_types[:sales]
            @settlement = Settlement.create(name: @client_account.name, amount: receipt_amount, description: description_bills, date_bs: @voucher.date_bs, settlement_type: settlement_type)
          end

          @voucher.particulars.each do |particular|
            particular.pending!

            ledger = Ledger.find(particular.ledger_id)
            # particular.bill_id = bill_id
            if (particular.cheque_number.present?)
              # make the additional_bank_id nil for payment
              bank_account = ledger.bank_account

              client_account_id = nil

              if !@voucher.is_payment_bank?
                client_account_id = ledger.client_account_id
              end

              # TODO track the cheque entries whether it is from client or the broker
              cheque_entry = ChequeEntry.find_or_create_by!(cheque_number: particular.cheque_number,bank_account_id: bank_account.id, additional_bank_id: particular.additional_bank_id, client_account_id: client_account_id)
              particular.cheque_entries << cheque_entry

            end

            unless @voucher.is_payment_bank

              ledger.lock!

              closing_blnc = ledger.closing_blnc
              ledger.closing_blnc = ( particular.dr?) ? closing_blnc + particular.amnt : closing_blnc - particular.amnt
              particular.opening_blnc = closing_blnc
              particular.running_blnc = ledger.closing_blnc
              particular.complete!
              ledger.save!
            end

          end
          @voucher.settlement = @settlement
          # mark the voucher as settled if it is not payment bank
          @voucher.complete! unless @voucher.is_payment_bank
          res = true if @voucher.save
        end
      else
        if has_error
          @error_message = error_message
        else
          @error_message = "Particulars should have balancing figures."
        end
      end
    else
      @error_message  = is_purchase_sales ? "Please include atleast 1 particular" : "Particulars should be atleast 2"
    end
    res
  end
end