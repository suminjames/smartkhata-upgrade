class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]
  before_action :set_selected_bills_settlement_params, only: [:process_selected]

  before_action :authorize_bill, only: [:index, :show_multiple, :sales_payment, :sales_payment_process, :process_selected, :select_for_settlement, :ageing_analysis]
  # also :authorize_single_bill(s) when implemented

  # layout 'application_custom', only: [:index]

  include BillModule

  # GET /bills
  # GET /bills.json
  def index
    # If logged in client tries to view information of clients which he doesn't have access to, redirect to home with
    # error flash message.
    if current_user.client? &&
        !current_user&.belongs_to_client_account(params.dig(:filterrific, :by_client_id).to_i)
      user_not_authorized and return
    end

    # Check if 'Process Selected Bill', and render accordingly.
    if params['search_by'] == 'client_id'
      @process_selected_bills = true
      @client_account_id = params['search_term'].to_i
      client_account= ClientAccount.find(@client_account_id)
      @bills = client_account.get_all_related_bills.by_branch_fy_code(selected_branch_id, selected_fy_code).order(date: :asc).decorate
      # render a separate page for bills selection
      render :select_for_settlement and return
    end

    @filterrific = initialize_filterrific(
        Bill.by_branch_fy_code(selected_branch_id, selected_fy_code),
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_bill_type: Bill.options_for_bill_type_select,
            by_bill_status: Bill.options_for_bill_status_select,
        },
        persistence_id: false
    ) or return

    if ['xlsx', 'pdf'].include? params[:format]
      @bills = @filterrific.find.order(bill_number: :asc).includes(:share_transactions => :isin_info).decorate
    else
      @bills = @filterrific.find.order(bill_number: :asc).includes(:share_transactions => :isin_info).page(params[:page]).per(20).decorate
    end

    @download_path_xlsx = bills_path({format:'xlsx'}.merge params)
    @download_path_pdf = bills_path({format:'pdf'}.merge params)

    respond_to do |format|
      format.html
      format.js
      format.xlsx do
        report = Reports::Excelsheet::BillsReport.new(@bills, params[:filterrific], current_tenant)
        send_data report.file, type: report.type, filename: report.filename
        report.clear
      end
      # format.pdf do
      # end
    end

      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = "#{ e.message }"
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET select_for_settlment
  def select_for_settlement
    @ledger_id = params['ledger_id'].to_i
    @sk_id = params['sk_id'] || nil
    @bills = []
    @client_account_id = nil
    @client_account_id = Ledger.find_by(id: @ledger_id).try(:client_account_id)
    if @client_account_id
      client_account= ClientAccount.find(@client_account_id)
      @bills = client_account.get_all_related_bills.order(date: :asc).decorate
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def ageing_analysis
    @filterrific = initialize_filterrific(
        # Show only purchase and unsettled bills. Used for ageing analysis report.
        Bill.by_branch_id(selected_branch_id).find_not_settled.purchase,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_bill_status: Bill.options_for_bill_status_select_for_ageing_analysis,
            by_bill_age: Bill.options_for_bill_age_select
        },
        persistence_id: false
    ) or return
    @bills = @filterrific.find.order(bill_number: :asc).includes(:share_transactions => :isin_info).page(params[:page]).per(20).decorate

    respond_to do |format|
      format.html
      format.js
    end


      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return

  end

  # GET /bills/1
  # GET /bills/1.json
  def show
    @from_path = request.referer
    @bill = Bill.by_branch_id(selected_branch_id).includes(:share_transactions => :isin_info).find(params[:id])
    authorize @bill
    @bill = @bill.decorate
    @has_voucher_pending_approval = false

    @bill.vouchers_on_settlement.each do |voucher|
      if voucher.pending?
        @has_voucher_pending_approval = true
        break
      end
    end

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintBill.new(@bill, current_tenant, 'for_print')
        send_data pdf.render, filename: "Bill_#{@bill.fy_code}_#{@bill.bill_number}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  def show_multiple
    bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?
    bills = Bill.by_branch_id(selected_branch_id).includes(:share_transactions => :isin_info).where(id: bill_ids).decorate
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintMultipleBills.new(bills, current_tenant, 'for_print')
        send_data pdf.render, filename: "MultipleBills.pdf", type: 'application/pdf', disposition: "inline"
      end
    end

  end

  # GET /bills/new
  def new
    @bill = Bill.new
    authorize @bill
  end

  # GET /bills/1/edit
  def edit
    raise NotImplementedError
  end

  # POST /bills
  # POST /bills.json
  def create
    @bill = Bill.new(bill_params).make_provisional
    authorize @bill

    res = false

    Bill.transaction do
      if @bill.errors.blank? && @bill.save
        res = true
      end
    end

    respond_to do |format|
      if res
        format.html { redirect_to @bill, notice: 'Bill was successfully created.' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
    #
    # raise NotImplementedError
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    # respond_to do |format|
    #   if @bill.update(bill_params)
    #     format.html { redirect_to @bill, notice: 'Bill was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @bill }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @bill.errors, status: :unprocessable_entity }
    #   end
    # end
    raise NotImplementedError
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    # @bill.destroy
    # respond_to do |format|
    #   format.html { redirect_to bills_url, notice: 'Bill was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
    raise NotImplementedError
  end

  def sales_payment
    @settlement_id = params[:settlement_id]
    if params[:settlement_id].present?
      @bank_payment_letter = BankPaymentLetter.new
      bank_account = BankAccount.by_branch_id(selected_branch_id).default_for_payment(selected_branch_id)

      cheque_entry = ChequeEntry.next_available_serial_cheque(bank_account.id) if bank_account.present?
      @cheque_number = cheque_entry.cheque_number if cheque_entry.present?

      @nepse_settlement = NepseSaleSettlement.find_by(settlement_id: params[:settlement_id])
      @bills = []
      @bills = @nepse_settlement.bills_for_sales_payment_list(@selected_branch_id) if @nepse_settlement.present?
      @is_searched = true
      return
    end
  end

  def sales_payment_process
    @settlement_id = params[:settlement_id]
    @cheque_number = params[:cheque_number].to_i
    @nepse_settlement = NepseSaleSettlement.find_by(id: params[:nepse_settlement_id])
    @bank_account = BankAccount.by_branch_id(selected_branch_id).find_by(id: params[:bank_account_id])
    bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?

    @back_path = request.referer
    if selected_fy_code != get_fy_code(@nepse_settlement.settlement_date)
      redirect_to @back_path, :flash => {:error => 'Please select the current fiscal year'} and return
    end

    process_sales_bill = ProcessSalesBillService.new(bill_ids: bill_ids, bank_account: @bank_account, nepse_settlement: @nepse_settlement , date: @nepse_settlement.settlement_date, cheque_number: @cheque_number, current_user: current_user, branch_id: @selected_branch_id)

    respond_to do |format|
      if process_sales_bill.process
        format.html { redirect_to pending_vouchers_vouchers_path, notice: 'Sales Settlement successfully created.' }
      else
        flash.now[:error] = process_sales_bill.error_message
        format.html { render :sales_payment }
      end
    end
  end

  def process_selected
    amount_margin_error = 0.01

    @back_path = request.referer || bills_path
    if @bill_ids.size <= 0

      redirect_to @back_path, :flash => {:error => 'No Bills were Selected'} and return
    end


    client_account = ClientAccount.find(@client_account_id)
    client_ledger = client_account.ledger
    ledger_balance = client_ledger.closing_balance

    bill_list = get_bills_from_ids(@bill_ids)
    bills_receive = bill_list.requiring_receive
    bills_payment = bill_list.requiring_payment
    amount_to_receive = bills_receive.sum(:balance_to_pay)
    amount_to_pay = bills_payment.sum(:balance_to_pay)

    # negative if the company has to pay
    # positive if the client needs to pay
    amount_to_receive_or_pay = amount_to_receive - amount_to_pay

    @processed_bills = []
    # if amount_to_receive_or_pay + amount_margin_error >= 0 && ledger_balance - amount_margin_error <= 0 || amount_to_receive_or_pay - amount_margin_error < 0 && ledger_balance + amount_margin_error >= 0
    #   Bill.transaction do
    #     bill_list.each do |bill|
    #       bill.balance_to_pay = 0
    #       bill.status = Bill.statuses[:settled]
    #       bill.save!
    #       @processed_bills << bill
    #     end
    #   end
    # else
      redirect_to new_voucher_path(client_account_id: @client_account_id, bill_ids: @bill_ids) and return
    # end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_bill
    # @bill = Bill.find(params[:id])
    # Used 'find_by_id' instead of 'find' to as the former returns nil if the object with the id not found
    # The bang operator '!' after find_by_id raises an error and halts the script
    @bill = Bill.by_branch_id(selected_branch_id).find_by_id!(params[:id]).decorate
  end

  def authorize_bill
    authorize Bill
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bill_params
    permitted_params = params.require(:bill).permit(:client_account_id, :date_bs, :provisional_base_price)
    with_branch_user_params(permitted_params)
  end


  def set_selected_bills_settlement_params
    # get parameters for voucher types and assign it as journal if not available
    @bill_ids = []
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?
  end

end
