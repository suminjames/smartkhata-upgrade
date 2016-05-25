class VouchersController < ApplicationController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy]
  before_action :set_voucher_general_params, only: [:new, :create]
  before_action :set_voucher_creation_params, only: [:create]

  # GET /vouchers
  # GET /vouchers.json
  def index
    @vouchers = Voucher.pending.order("id ASC").decorate
  end

  def pending_vouchers
    @vouchers = Voucher.pending.order("id ASC").decorate
    render :index
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
    @from_path =  request.referer || pending_vouchers_vouchers_path
    full_view = params[:full] || false
    @particulars = @voucher.particulars
    if @voucher.is_payment_bank && !full_view
      @from_path = vouchers_path if @from_path.match(/new/)
      # TODO remove this hack
      @particular_with_bank = @particulars.has_bank.first
      @bank_account = @particular_with_bank.ledger.bank_account
      @cheque = @particular_with_bank.cheque_number
      @particulars =  @particulars.general
    end
  end

  # GET /vouchers/new
  # POST /vouchers/new
  def new
    @voucher, @is_payment_receipt, @ledger_list_financial, @ledger_list_available, @default_ledger_id, @voucher_type, @vendor_account_list, @client_ledger_list =
        Vouchers::Setup.new(voucher_type: @voucher_type,
                            client_account_id: @client_account_id,
                            bill_id: @bill_id,
                            clear_ledger: @clear_ledger,
                            bill_ids: @bill_ids).voucher_and_relevant
    puts @voucher_type
  end

  # GET /vouchers/1/edit
  def edit
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    # ignore some validations when the voucher type is sales or purchase
    @is_payment_receipt = false
    # create voucher with the posted parameters
    @voucher = Voucher.new(voucher_params)
    voucher_creation = Vouchers::Create.new(voucher_type: @voucher_type,
                                            client_account_id: @client_account_id,
                                            bill_id: @bill_id,
                                            clear_ledger: @clear_ledger,
                                            voucher: @voucher,
                                            bill_ids: @bill_ids,
                                            voucher_settlement_type: @voucher_settlement_type,
                                            group_leader_ledger_id: @group_leader_ledger_id,
                                            vendor_account_id: @vendor_account_id)

    # abort("Message goes here")
    respond_to do |format|
      if voucher_creation.process

        @voucher = voucher_creation.voucher
        settlements = @voucher.settlements

        format.html {
          if settlements.size > 0 && !@voucher.is_payment_bank?
            settlement_ids = settlements.pluck(:id)
            # TODO (Remove this hack to show all the settlements)
            redirect_to show_multiple_settlements_path(settlement_ids: settlement_ids)
          else
            redirect_to @voucher, notice: 'Voucher was successfully created.'
          end
        }
        format.json { render :show, status: :created, location: @voucher }
      else
        @voucher = voucher_creation.voucher

        # ledger list and is purchase sales is required for the extra section to show up for payment and receipt case
        # ledger list financial contains only bank ledgers and cash ledger
        # ledger list no banks contains all ledgers except banks (to avoid bank transfers using voucher)
        @ledger_list_financial = voucher_creation.ledger_list_financial
        @ledger_list_available = voucher_creation.ledger_list_available
        @vendor_account_list = voucher_creation.vendor_account_list
        @client_ledger_list = voucher_creation.client_ledger_list
        @is_payment_receipt = voucher_creation.is_payment_receipt?(@voucher_type)
        @voucher_settlement_type  = voucher_creation.voucher_settlement_type
        @group_leader_ledger_id  = voucher_creation.group_leader_ledger_id
        @vendor_account_id = voucher_creation.vendor_account_id

        if voucher_creation.error_message
          flash.now[:error] = voucher_creation.error_message
        end

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

  # TODO make sure authorization is performed

  def finalize_payment
    success = false
    error_message = "There was some Error"
    @voucher = Voucher.find_by(id: params[:id].to_i)
    from_path = params[:from_path] || '/vouchers/index'
    message = ""
    if @voucher
      if !@voucher.rejected? && !@voucher.complete?
        if params[:approve]
          Voucher.transaction do
            @voucher.particulars.each do |particular|
              ledger = Ledger.find(particular.ledger_id)
              ledger.lock!

              closing_blnc = ledger.closing_blnc
              ledger.closing_blnc = ( particular.dr?) ? closing_blnc + particular.amount : closing_blnc - particular.amount
              particular.opening_blnc = closing_blnc
              particular.running_blnc = ledger.closing_blnc
              particular.complete!
              ledger.save!
            end

            @voucher.cheque_entries.uniq.each do |cheque_entry|
              cheque_entry.approved!
            end

            @voucher.reviewer_id = UserSession.user_id
            @voucher.complete!
            @voucher.save!
            success = true
            message = "Payment Voucher was successfully approved"
          end
        elsif  params[:reject]
          # TODO(Subas) what happens to bill
          @voucher.reviewer_id = UserSession.user_id

          @voucher.cheque_entries.uniq.each do |cheque_entry|
            cheque_entry.void!
          end

          @voucher.rejected!
          success = true if @voucher.save!
          message = 'Payment Voucher was successfully rejected'
        end
      else
        error_message = 'Voucher is already processed.'
      end

    end



    # TODO remove what the fuck
    respond_to do |format|
      format.html {
        redirect_to from_path, notice: message  if success
        redirect_to from_path, alert: error_message unless success
      }
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
    when Voucher.voucher_types[:receipt]
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

    when Voucher.voucher_types[:payment]
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voucher
      @voucher = Voucher.find(params[:id]).decorate
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voucher_params
      params.require(:voucher).permit(:date_bs, :voucher_type, :desc, particulars_attributes: [:ledger_id,:description, :amount,:transaction_type, :cheque_number, :additional_bank_id])
    end

  def set_voucher_general_params
    # get parameters for voucher types and assign it as journal if not available
    @bill_ids = []
    @voucher_type = params[:voucher_type].to_i if params[:voucher_type].present? || Voucher.voucher_types[:journal]
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    # get bill id if present
    @bill_id = params[:bill_id].to_i if params[:bill_id].present?
    @bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?
    # check if clear ledger balance is present
    @clear_ledger = set_clear_ledger
  end

  def set_voucher_creation_params
    @fixed_ledger_id = params[:fixed_ledger_id].to_i if params[:fixed_ledger_id].present?
    @cheque_number = params[:cheque_number].to_i if params[:cheque_number].present?
    @voucher_settlement_type = params[:voucher_settlement_type] if params[:voucher_settlement_type].present?
    @group_leader_ledger_id = params[:group_leader_ledger_id].to_i if params[:group_leader_ledger_id].present?
    @vendor_account_id = params[:vendor_account_id].to_i if params[:vendor_account_id].present?
  end

  # special case for which the ledger balance can be cleared all at once
  def set_clear_ledger
    clear_ledger = false
    if params[:clear_ledger].present?
      return true if ( params[:clear_ledger] == true || params[:clear_ledger] == 'true')
    end
    clear_ledger
  end

end