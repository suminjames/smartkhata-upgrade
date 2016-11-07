class MasterSetup::CommissionRatesController < ApplicationController
  before_action :set_master_setup_commission_rate, only: [:show, :edit, :update, :destroy]

  # GET /master_setup/commission_rates
  # GET /master_setup/commission_rates.json
  def index
    @master_setup_commission_rates = MasterSetup::CommissionRate.all
  end

  # GET /master_setup/commission_rates/1
  # GET /master_setup/commission_rates/1.json
  def show
  end

  # GET /master_setup/commission_rates/new
  def new
    @master_setup_commission_rate = MasterSetup::CommissionRate.new
  end

  # GET /master_setup/commission_rates/1/edit
  def edit
  end

  # POST /master_setup/commission_rates
  # POST /master_setup/commission_rates.json
  def create
    @master_setup_commission_rate = MasterSetup::CommissionRate.new(master_setup_commission_rate_params)

    respond_to do |format|
      if @master_setup_commission_rate.save
        format.html { redirect_to @master_setup_commission_rate, notice: 'Commission rate was successfully created.' }
        format.json { render :show, status: :created, location: @master_setup_commission_rate }
      else
        format.html { render :new }
        format.json { render json: @master_setup_commission_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_setup/commission_rates/1
  # PATCH/PUT /master_setup/commission_rates/1.json
  def update
    respond_to do |format|
      if @master_setup_commission_rate.update(master_setup_commission_rate_params)
        format.html { redirect_to @master_setup_commission_rate, notice: 'Commission rate was successfully updated.' }
        format.json { render :show, status: :ok, location: @master_setup_commission_rate }
      else
        format.html { render :edit }
        format.json { render json: @master_setup_commission_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_setup/commission_rates/1
  # DELETE /master_setup/commission_rates/1.json
  def destroy
    @master_setup_commission_rate.destroy
    respond_to do |format|
      format.html { redirect_to master_setup_commission_rates_url, notice: 'Commission rate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master_setup_commission_rate
      @master_setup_commission_rate = MasterSetup::CommissionRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_setup_commission_rate_params
      params.require(:master_setup_commission_rate).permit(:date_from, :date_to, :amount_gt, :amout_lt_eq, :rate, :is_flat_rate, :remarks)
    end
end
