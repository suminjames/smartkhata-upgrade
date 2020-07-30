class MasterSetup::InterestRatesController < ApplicationController
  before_action :set_master_setup_interest_rate, only: [:show, :edit, :update, :destroy]

  # GET /master_setup/interest_rates
  # GET /master_setup/interest_rates.json
  def index
    @master_setup_interest_rates = MasterSetup::InterestRate.all
  end

  # GET /master_setup/interest_rates/1
  # GET /master_setup/interest_rates/1.json
  def show
  end

  # GET /master_setup/interest_rates/new
  def new
    @master_setup_interest_rate = MasterSetup::InterestRate.new
  end

  # GET /master_setup/interest_rates/1/edit
  def edit
  end

  # POST /master_setup/interest_rates
  # POST /master_setup/interest_rates.json
  def create
    @master_setup_interest_rate = MasterSetup::InterestRate.new(master_setup_interest_rate_params)

    respond_to do |format|
      if @master_setup_interest_rate.save
        format.html { redirect_to @master_setup_interest_rate, notice: 'Interest rate was successfully created.' }
        format.json { render :show, status: :created, location: @master_setup_interest_rate }
      else
        format.html { render :new }
        format.json { render json: @master_setup_interest_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_setup/interest_rates/1
  # PATCH/PUT /master_setup/interest_rates/1.json
  def update
    respond_to do |format|
      if @master_setup_interest_rate.update(master_setup_interest_rate_params)
        format.html { redirect_to @master_setup_interest_rate, notice: 'Interest rate was successfully updated.' }
        format.json { render :show, status: :ok, location: @master_setup_interest_rate }
      else
        format.html { render :edit }
        format.json { render json: @master_setup_interest_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_setup/interest_rates/1
  # DELETE /master_setup/interest_rates/1.json
  def destroy
    @master_setup_interest_rate.destroy
    respond_to do |format|
      format.html { redirect_to master_setup_interest_rates_url, notice: 'Interest rate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master_setup_interest_rate
      @master_setup_interest_rate = MasterSetup::InterestRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_setup_interest_rate_params
      params.require(:master_setup_interest_rate).permit(:start_date, :end_date, :interest_type, :rate)
    end
end
