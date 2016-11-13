class SettlementsController < ApplicationController
  before_action :set_settlement, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @settlement}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize Settlement}, only: [:index, :new, :create, :show_multiple]

  # GET /settlements
  # GET /settlements.json
  def index
    @filterrific = initialize_filterrific(
        Settlement,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_settlement_type: Settlement.options_for_settlement_type_select
        },
        persistence_id: false
    ) or return

    items_per_page = 20
    # Note: Don't show void vouchers.
    # In case of cheque creation during voucher client_account_id is not assigned to the cheques
    # to compensate that or condition is inserted

    order_parameter = params.dig(:filterrific, :by_settlement_type) == 'payment' ? 'cheque_entries.cheque_number ASC' : 'settlements.date ASC, settlements.updated_at ASC'

    # TODO(sarojk): Due to new implmentation of model associations, where conditions below are probably redundant. Get rid of them as necessary after migration.
    if ['xlsx', 'pdf'].include?(params[:format])
      @settlements = @filterrific.find.not_rejected.includes(:cheque_entries => [{:bank_account => :bank}, :additional_bank]).order(order_parameter).where.not(cheque_entries: {id: nil}).references(:cheque_entries).decorate
    else
      @settlements = @filterrific.find.not_rejected.includes(:cheque_entries => [{:bank_account => :bank}, :additional_bank]).order(order_parameter).where.not(cheque_entries: {id: nil}).references(:cheque_entries).page(params[:page]).per(items_per_page).decorate

    # void_int = ChequeEntry.statuses[:void]
    # bounced_int = ChequeEntry.statuses[:bounced]

    # if ['xlsx', 'pdf'].include?(params[:format])
    #   # @settlements = @filterrific.find.not_rejected.includes(:voucher => {:cheque_entries => [{:bank_account => :bank}, :additional_bank]}).where('settlements.client_account_id = cheque_entries.client_account_id OR cheque_entries.client_account_id is NULL').order(order_parameter).references(:cheque_entries).decorate
    #   @settlements = @filterrific.find.not_rejected.includes(:voucher => {:cheque_entries => [{:bank_account => :bank}, :additional_bank]}).where("(cheque_entries.status IS NULL OR (cheque_entries.status != :void_int AND cheque_entries.status != :bounced_int)) AND (settlements.client_account_id = cheque_entries.client_account_id OR cheque_entries.client_account_id is NULL)", :void_int => void_int, :bounced_int => bounced_int).order(order_parameter).references(:cheque_entries).decorate
    # else
    #   # @settlements = @filterrific.find.not_rejected.includes(:voucher => {:cheque_entries => [{:bank_account => :bank}, :additional_bank]}).where('settlements.client_account_id = cheque_entries.client_account_id OR cheque_entries.client_account_id is NULL').order(order_parameter).references(:cheque_entries).page(params[:page]).per(items_per_page).decorate
    #   @settlements = @filterrific.find.not_rejected.includes(:voucher => {:cheque_entries => [{:bank_account => :bank}, :additional_bank]}).where("(cheque_entries.status IS NULL OR (cheque_entries.status != :void_int AND cheque_entries.status != :bounced_int)) AND (settlements.client_account_id = cheque_entries.client_account_id OR cheque_entries.client_account_id is NULL)", :void_int => void_int, :bounced_int => bounced_int).order(order_parameter).references(:cheque_entries).page(params[:page]).per(items_per_page).decorate
    end


    @download_path_xlsx = settlements_path({format:'xlsx'}.merge params)
    respond_to do |format|
      format.html
      format.xlsx do
        report = Reports::Excelsheet::SettlementsReport.new(@settlements, params[:filterrific], current_tenant)
        send_data report.file, type: report.type, filename: report.filename
        report.clear
      end
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

  # GET /settlements/1
  # GET /settlements/1.json
  def show
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintSettlement.new(@settlement, current_tenant)
        send_data pdf.render, filename: "Settlement_#{@settlement.id}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  def show_multiple
    @settlement_ids = params[:settlement_ids].map(&:to_i) if params[:settlement_ids].present?
    @settlements = Settlement.where(id: @settlement_ids)
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintMultipleSettlements.new(@settlements, current_tenant)
        send_data pdf.render, filename: "MultipleSettlements_#{@settlement_ids.to_s}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  # GET /settlements/new
  def new
    @settlement = Settlement.new
  end

  # GET /settlements/1/edit
  def edit
  end

  # POST /settlements
  # POST /settlements.json
  def create
    @settlement = Settlement.new(settlement_params)

    respond_to do |format|
      if @settlement.save
        format.html { redirect_to @settlement, notice: 'Settlement was successfully created.' }
        format.json { render :show, status: :created, location: @settlement }
      else
        format.html { render :new }
        format.json { render json: @settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settlements/1
  # PATCH/PUT /settlements/1.json
  def update
    respond_to do |format|
      if @settlement.update(settlement_params)
        format.html { redirect_to @settlement, notice: 'Settlement was successfully updated.' }
        format.json { render :show, status: :ok, location: @settlement }
      else
        format.html { render :edit }
        format.json { render json: @settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settlements/1
  # DELETE /settlements/1.json
  def destroy
    @settlement.destroy
    respond_to do |format|
      format.html { redirect_to settlements_url, notice: 'Settlement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_settlement
    @settlement = Settlement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def settlement_params
    params.require(:settlement).permit(:name, :amount, :date_bs, :description, :settlement_type, :voucher_id)
  end
end
