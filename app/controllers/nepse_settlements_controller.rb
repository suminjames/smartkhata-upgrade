class NepseSettlementsController < ApplicationController
  before_action :set_nepse_settlement, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize @nepse_settlement}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize NepseSettlement}, only: [:index, :new, :create, :generate_bills]

  # helper for smart listing
  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper

  # GET /nepse_settlements
  # GET /nepse_settlements.json
  def index
    if params[:pending]
      @nepse_settlements = NepseSettlement.pending.order(settlement_id: :desc)
    else
      @nepse_settlements = NepseSettlement.all.order(settlement_id: :desc)
    end

  end

  # GET /nepse_settlements/1
  # GET /nepse_settlements/1.json
  def show
    #TODO move this to model
    @share_transactions = ShareTransaction.where(settlement_id: @nepse_settlement.settlement_id, deleted_at: nil)
    @receipt_bank_account = BankAccount.by_branch_id.where(:default_for_payment => true).first
    if @nepse_settlement.complete?
      @share_transactions_raw = smart_listing_create(:share_transactions, @share_transactions, partial: "share_transactions/list_complete", page_sizes: [50])
    else
      @share_transactions_raw = smart_listing_create(:share_transactions, @share_transactions, partial: "share_transactions/list", page_sizes: [50])
    end
  end

  # GET /nepse_settlements/new
  def new
    @nepse_settlement = NepseSettlement.new
  end

  # GET /nepse_settlements/1/edit
  def edit
  end

  # POST /nepse_settlements
  # POST /nepse_settlements.json
  def create
    @nepse_settlement = NepseSettlement.new(nepse_settlement_params)

    respond_to do |format|
      if @nepse_settlement.save
        format.html { redirect_to @nepse_settlement, notice: 'Sales settlement was successfully created.' }
        format.json { render :show, status: :created, location: @nepse_settlement }
      else
        format.html { render :new }
        format.json { render json: @nepse_settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nepse_settlements/1
  # PATCH/PUT /nepse_settlements/1.json
  def update
    respond_to do |format|
      if @nepse_settlement.update(nepse_settlement_params)
        format.html { redirect_to @nepse_settlement, notice: 'Sales settlement was successfully updated.' }
        format.json { render :show, status: :ok, location: @nepse_settlement }
      else
        format.html { render :edit }
        format.json { render json: @nepse_settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nepse_settlements/1
  # DELETE /nepse_settlements/1.json
  def destroy
    @nepse_settlement.destroy
    respond_to do |format|
      format.html { redirect_to nepse_settlements_url, notice: 'Sales settlement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # generate bills for the sale settlement
  def generate_bills
    @nepse_settlement = NepseSettlement.find(params[:id])

    # check if the sales settlement is pending
    # return with error message if otherwise
    unless @nepse_settlement.pending?
      flash.now[:error] = "It has already been processed"
      @error = true
      return
    end

    # process the sale settlement
    @status = GenerateBillsService.new(nepse_settlement: @nepse_settlement).process
  end



  private
  # Use callbacks to share common setup or constraints between actions.
  def set_nepse_settlement
    @nepse_settlement = NepseSettlement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def nepse_settlement_params
    params.fetch(:nepse_settlement, {})
  end
end
