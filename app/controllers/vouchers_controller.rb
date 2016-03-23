class VouchersController < ApplicationController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy]

  # GET /vouchers
  # GET /vouchers.json
  def index
    @vouchers = Voucher.all
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
    @particulars = @voucher.particulars
  end

  # GET /vouchers/new
  def new
    # get parameters for voucher types
    @voucher_type = Voucher.voucher_types[params[:voucher_type]] || Voucher.voucher_types[:journal]
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    # get bill id if present
    @bill_id = params[:bill_id].to_i if params[:bill_id].present?
    # ignore some validations when the voucher type is sales or purchase
    @is_purchase_sales = false

    # create new voucher
    @voucher = Voucher.new

    # load additional data for voucher types
    # client purchase is voucher type sales
    # client sales is voucher type purchase
    if @voucher_type == Voucher.voucher_types[:sales] || @voucher_type == Voucher.voucher_types[:purchase]
      @is_purchase_sales = true
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @default_bank_purchase = BankAccount.where(:default_for_purchase => true).first
      @default_bank_sales = BankAccount.where(:default_for_sales   => true).first
      @cash_ledger = Ledger.find_by(name: "Cash")
      @ledger_list << @cash_ledger

      if @voucher_type == Voucher.voucher_types[:sales]
        @default_ledger_id = @default_bank_sales ? @default_bank_sales.id : @cash_ledger.id
      else
        @default_ledger_id = @default_bank_purchase ? @default_bank_purchase.id : @cash_ledger.id
      end

    end

    @client_account,@bill,@bills,@amount = set_bill_client(@client_account_id, @bill_id, @voucher_type)

    # if client account is present create a particular with available information and assign it
    # else create a particulars
    @voucher.particulars = []
    if @is_purchase_sales
      transaction_type = @voucher_type == Voucher.voucher_types[:sales] ? Particular.transaction_types[:dr] : Particular.transaction_types[:cr]
      @voucher.particulars << Particular.new(ledger_id: @default_ledger_id,amnt: @amount, transaction_type: transaction_type)
    end

    @voucher.particulars <<  Particular.new(ledger_id: @client_account.ledger.id,amnt: @amount) if @client_account.present?
    @voucher.particulars << Particular.new if @client_account.nil?

  end

  # GET /vouchers/1/edit
  def edit
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    # get parameters for voucher types
    @voucher_type =  params[:voucher_type].present? ? params[:voucher_type].to_i : 0
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @bill_id = params[:bill_id].to_i if params[:bill_id].present?

    # fixed ledger is the ledger for sales and purchase
    @fixed_ledger_id = params[:fixed_ledger_id].to_i if params[:fixed_ledger_id].present?
    @cheque_number = params[:cheque_number].to_i if params[:cheque_number].present?

    # ignore some validations when the voucher type is sales or purchase
    @is_purchase_sales = false

    # create voucher with the posted parameters
    @voucher = Voucher.new(voucher_params)
    @voucher.voucher_type = @voucher_type

    # ledgers need to be pre populated for sales and purchase type
    case @voucher_type
    when Voucher.voucher_types[:sales],Voucher.voucher_types[:purchase]
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @ledger_list << Ledger.find_by(name: "Cash")
      @is_purchase_sales = true
    end


    # convert the bs date to english date for storage
    cal = NepaliCalendar::Calendar.new
    bs_string_arr =  @voucher.date_bs.to_s.split(/-/)
    @voucher.date = cal.bs_to_ad(bs_string_arr[0],bs_string_arr[1], bs_string_arr[2])

    # get a calculated values, these are returned nil if not applicable
    @client_account, @bill, @bills, @amount_to_pay_receive = set_bill_client(@client_account_id, @bill_id, @voucher_type)

    # to track if the voucher can be saved.
    success = false
    has_error = false
    error_message = ""
    net_blnc = 0
    receipt_amount = 0


    # for voucher type sales and purchase the partiulars can be one but not 0
    # as we add a counter balancing particulars dynamically
    # for other types it has to be atleast 2
    if @voucher.particulars.length > 1 || (@is_purchase_sales && @voucher.particulars.length > 0)
      # check if debit equal credit or amount is not zero
      @voucher.particulars.each do |particular|
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
      end

      # add the particular to the voucher for sales or purchase
      @processed_bills = []
      # capture  the bill number and amount billed to description billed
      description_bills = ""
      if (@is_purchase_sales)
        transaction_type = net_blnc >= 0 ? Particular.transaction_types[:cr] : Particular.transaction_types[:dr]
        receipt_amount = net_blnc.abs
        net_blnc = net_blnc.abs
        @bills.each do |bill|
          if bill.balance_to_pay <= net_blnc
            net_blnc = net_blnc - bill.balance_to_pay
            description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number} Amount: #{bill.balance_to_pay}  "
            bill.balance_to_pay = 0
            bill.status = Bill.statuses[:settled]
            @processed_bills << bill
          else
            bill.status = Bill.statuses[:partial]
            description_bills += "Bill No.:#{bill.fy_code}-#{bill.bill_number} Amount: #{net_blnc}  "
            bill.balance_to_pay = bill.balance_to_pay - net_blnc
            @processed_bills << bill
            break
          end
        end

        # append the manually created particular to the list of  voucher particulars
        particular_single = Particular.new(ledger_id: @fixed_ledger_id, transaction_type: transaction_type, cheque_number: @cheque_number, amnt: receipt_amount)
        @voucher.particulars << particular_single
        net_blnc = 0
      end

      # add the ledger name in case of 2 particulars
      if @voucher.particulars.length == 2 && !has_error
        @voucher.particulars[0].name = Ledger.find(@voucher.particulars[1].ledger_id).name
        @voucher.particulars[1].name = Ledger.find(@voucher.particulars[0].ledger_id).name
      end

      # make changes in ledger balances and save the voucher
      if net_blnc == 0 && has_error == false
        Voucher.transaction do
          @receipt = nil
          @processed_bills.each(&:save)
          @voucher.bills << @processed_bills

          # TODO add the cheque tracking to receipt
          # TODO add bill tracking to receipt
          # TODO add number to receipt
          # TODO add client tracking

          if @is_purchase_sales && !@processed_bills.blank?
            settlement_type = Settlement.settlement_types[:payment]
            settlement_type = Settlement.settlement_types[:receipt] if @voucher_type == Voucher.voucher_types[:sales]
            @settlement = Settlement.create(name: @client_account.name, amount: receipt_amount, description: description_bills, date_bs: @voucher.date_bs, settlement_type: settlement_type)
          end

          @voucher.particulars.each do |particular|

            ledger = Ledger.find(particular.ledger_id)
            # particular.bill_id = bill_id
            if (particular.cheque_number.present?)
              bank_account = ledger.bank_account
              # TODO track the cheque entries whether it is from client or the broker
              cheque_entry = ChequeEntry.find_or_create_by!(cheque_number: particular.cheque_number,bank_account_id: bank_account.id)
              particular.cheque_entries << cheque_entry
            end

            # Receipt.find_or_create_by()

            closing_blnc = ledger.closing_blnc
            ledger.closing_blnc = ( particular.dr?) ? closing_blnc + particular.amnt : closing_blnc - particular.amnt
            particular.opening_blnc = closing_blnc
            particular.running_blnc = ledger.closing_blnc
            ledger.save
          end
          @voucher.settlement = @settlement
          success = true if @voucher.save

        end
      else
        if has_error
           flash.now[:error] = error_message
        else
           flash.now[:error] = "Particulars should have balancing figures."
        end
      end
    else
      flash.now[:error] = @is_purchase_sales ? "Please include atleast 1 particular" : "Particulars should be atleast 2"
    end

    # abort("Message goes here")
    respond_to do |format|
      if success
        format.html {
          redirect_to settlement_path(@settlement) if @settlement.present?
          redirect_to @voucher, notice: 'Voucher was successfully created.' if @settlement.nil?
        }
        format.json { render :show, status: :created, location: @voucher }
      else
        format.html { render :new }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vouchers/1
  # PATCH/PUT /vouchers/1.json
  def update
    respond_to do |format|
      if @voucher.update(voucher_params)
        format.html { redirect_to @voucher, notice: 'Voucher was successfully updated.' }
        format.json { render :show, status: :ok, location: @voucher }
      else
        format.html { render :edit }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vouchers/1
  # DELETE /vouchers/1.json
  def destroy
    @voucher.destroy
    respond_to do |format|
      format.html { redirect_to vouchers_url, notice: 'Voucher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # returns client account, bill, group of bills and amount to be paid
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
    return client_account, bill, bills, amount
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voucher
      @voucher = Voucher.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voucher_params
      params.require(:voucher).permit(:date_bs, :voucher_type, :desc, particulars_attributes: [:ledger_id,:description, :amnt,:transaction_type])
    end
end
