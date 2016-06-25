class SalesSettlementsController < ApplicationController
  before_action :set_sales_settlement, only: [:show, :edit, :update, :destroy]
  # helper for smart listing
  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper

  # GET /sales_settlements
  # GET /sales_settlements.json
  def index
    if params[:pending]
      @sales_settlements = SalesSettlement.pending
    else
      @sales_settlements = SalesSettlement.all
    end

  end

  # GET /sales_settlements/1
  # GET /sales_settlements/1.json
  def show
    #TODO move this to model
    @share_transactions = ShareTransaction.where(settlement_id: @sales_settlement.settlement_id, deleted_at: nil)
    if @sales_settlement.complete?
      @share_transactions_raw = smart_listing_create(:share_transactions, @share_transactions, partial: "share_transactions/list_complete", page_sizes: [50])
    else
      @share_transactions_raw = smart_listing_create(:share_transactions, @share_transactions, partial: "share_transactions/list", page_sizes: [50])
    end
  end

  # GET /sales_settlements/new
  def new
    @sales_settlement = SalesSettlement.new
  end

  # GET /sales_settlements/1/edit
  def edit
  end

  # POST /sales_settlements
  # POST /sales_settlements.json
  def create
    @sales_settlement = SalesSettlement.new(sales_settlement_params)

    respond_to do |format|
      if @sales_settlement.save
        format.html { redirect_to @sales_settlement, notice: 'Sales settlement was successfully created.' }
        format.json { render :show, status: :created, location: @sales_settlement }
      else
        format.html { render :new }
        format.json { render json: @sales_settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_settlements/1
  # PATCH/PUT /sales_settlements/1.json
  def update
    respond_to do |format|
      if @sales_settlement.update(sales_settlement_params)
        format.html { redirect_to @sales_settlement, notice: 'Sales settlement was successfully updated.' }
        format.json { render :show, status: :ok, location: @sales_settlement }
      else
        format.html { render :edit }
        format.json { render json: @sales_settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_settlements/1
  # DELETE /sales_settlements/1.json
  def destroy
    @sales_settlement.destroy
    respond_to do |format|
      format.html { redirect_to sales_settlements_url, notice: 'Sales settlement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def generate_bills
    @sales_settlement = SalesSettlement.find(params[:id])
    # check if the sales settlement is pending
    # return with error message if otherwise
    unless @sales_settlement.pending?
      flash.now[:error] = "It has already been processed"
      @error = true
      return
    end

    # process the sale settlement
    @status = GenerateBillsService.new(sales_settlement: @sales_settlement).process

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sales_settlement
    @sales_settlement = SalesSettlement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sales_settlement_params
    params.fetch(:sales_settlement, {})
  end
end
