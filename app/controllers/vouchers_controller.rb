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
    @voucher_type = Voucher.voucher_types[params[:voucher_type]]
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    # get bill id if present
    @bill_id = @bill_id.to_i if params[:bill_id].present?

    @bill = nil
    @amount =  0.0
    # find the bills for the client
    if @client_account_id.present?
      @client_account = ClientAccount.find(@client_account_id)
      @bills = @client_account.bills.requiring_processing
      @amount = @bills.sum(:net_amount)
    elsif @bill_id.present?
      @bill = Bill.find(@bill_id)
      @bills = [@bill]
      @client_account = @bill.client_account

    end



    # create new voucher
    @voucher = Voucher.new

    # load additional data for voucher types
    # client purchase is voucher type sales
    # client sales is voucher type purchase

    case @voucher_type
    when Voucher.voucher_types[:sales]
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @ledger_list << Ledger.find_by(name: "Cash")

      if @client_account.present?
        unless @bill.present?
          @bills = @client_account.bills.requiring_receive
        else
          @bills = [@bill]
        end

        @amount = @bills.sum(:balance_to_pay)
        @amount = @amount < 0 ? 0 : @amount.abs
        @voucher.particulars = [Particular.new(ledger_id: @client_account.ledger.id,amnt: @amount)]
      end

    when Voucher.voucher_types[:purchase]
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @ledger_list << Ledger.find_by(name: "Cash")

      if @client_account.present?

        unless @bill.present?
          @bills = @client_account.bills.requiring_payment
        else
          @bills = [@bill]
        end

        @amount = @bills.sum(:balance_to_pay)
        @amount = @amount > 0 ? 0 : @amount.abs
        @voucher.particulars = [Particular.new(ledger_id: @client_account.ledger.id,amnt: @amount)]

      end

    end

    @voucher.particulars = [Particular.new] if @client_account.nil?

  end

  # GET /vouchers/1/edit
  def edit
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    # get parameters for voucher types
    @voucher_type = params[:voucher_type].to_i if params[:voucher_type].present?
    # client account id ensures the vouchers are on the behalf of the client
    @clent_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    # fixed ledger is the ledger for sales and purchase
    @fixed_ledger_id = params[:fixed_ledger_id].to_i if params[:fixed_ledger_id].present?
    @cheque_number = params[:cheque_number].to_i if params[:cheque_number].present?

    # ignore some validations when the voucher type is sales or purchase
    @is_purchase_sales = false

    # ledgers need to be pre populated for sales and purchase type
    case @voucher_type
    when Voucher.voucher_types[:sales],Voucher.voucher_types[:purchase]
      @ledger_list = BankAccount.all.uniq.collect(&:ledger)
      @ledger_list << Ledger.find_by(name: "Cash")
      @is_purchase_sales = true
    end
    # @ledger_list = BankAccount.all.uniq.collect(&:ledger)
    # @ledger_list << Ledger.find_by(name: "Cash")

    @voucher = Voucher.new(voucher_params)
    @cal = NepaliCalendar::Calendar.new
    bs_string_arr =  @voucher.date_bs.to_s.split(/-/)
    @voucher.date = @cal.bs_to_ad(bs_string_arr[0],bs_string_arr[1], bs_string_arr[2])

    # to track if the voucher can be saved.
    @success = false
    @has_error = false
    @error_message = ""
    @net_blnc = 0;

    # for voucher type sales and purchase the partiulars can be one but not 0
    # as we add a counter balancing particulars dynamically
    # for other types it has to be atleast 2
    if @voucher.particulars.length > 1 || (@is_purchase_sales && @voucher.particulars.length > 0)
      # check if debit equal credit or amount is not zero
      @voucher.particulars.each do |particular|
        if particular.amnt == 0
          @has_error = true
          @error_message ="Dont act smart."
          break
        elsif particular.ledger_id.nil?
          @has_error = true
          @error_message ="Dont act smart. Particulars cant be empty"
          break
        end
        (particular.dr?) ? @net_blnc += particular.amnt : @net_blnc -= particular.amnt
      end


      # add the particular to the voucher for sales or purchase
      if (@is_purchase_sales)
        transaction_type = @net_blnc >= 0 ? Particular.transaction_types[:cr] : Particular.transaction_types[:dr]
        particular_single = Particular.new(ledger_id: @fixed_ledger_id, transaction_type: transaction_type, cheque_number: @cheque_number, amnt: @net_blnc)
        @voucher.particulars << particular_single
        @net_blnc = 0
      end

      # add the ledger name in case of 2 particulars
      if @voucher.particulars.length == 2 && !@has_error
        @voucher.particulars[0].name = Ledger.find(@voucher.particulars[1].ledger_id).name
        @voucher.particulars[1].name = Ledger.find(@voucher.particulars[0].ledger_id).name
      end

      # make changes in ledger balances and save the voucher
      if @net_blnc == 0 && @has_error == false
        Voucher.transaction do
          @voucher.particulars.each do |particular|
            ledger = Ledger.find(particular.ledger_id)
            closing_blnc = ledger.closing_blnc
            ledger.closing_blnc = ( particular.dr?) ? closing_blnc + particular.amnt : closing_blnc - particular.amnt
            particular.opening_blnc = closing_blnc
            particular.running_blnc = ledger.closing_blnc
            ledger.save
          end
          @success = true if @voucher.save
        end
      else
        if @has_error
           flash.now[:error] = @error_message
        else
           flash.now[:error] = "Particulars should have balancing figures."
        end
      end
    else
      flash.now[:error] = @is_purchase_sales ? "Please include atleast 1 particular" : "Particulars should be atleast 2"
    end



    # abort("Message goes here")
    respond_to do |format|
      if @success
        format.html { redirect_to @voucher, notice: 'Voucher was successfully created.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voucher
      @voucher = Voucher.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voucher_params
      params.require(:voucher).permit(:date_bs, :desc, particulars_attributes: [:ledger_id,:description, :amnt,:transaction_type])
    end
end
