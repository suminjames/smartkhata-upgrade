class SettlementsController < ApplicationController
  before_action :set_settlement, only: [:show, :edit, :update, :destroy]

  # has_scope
  has_scope :by_settlement_type, only: :index
  has_scope :by_client_id, only: :index
  has_scope :by_vendor_id, only: :index
  has_scope :by_fy_code, only: :index
  has_scope :by_date, only: :index
  has_scope :by_date_range, :using => [:date_from, :date_to], :type => :hash, only: :index

  # GET /settlements
  # GET /settlements.json
  def index
    @settlements = apply_scopes(Settlement.all)
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
