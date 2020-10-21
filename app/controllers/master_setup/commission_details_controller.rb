class MasterSetup::CommissionDetailsController < ApplicationController
  before_action :set_master_setup_commission_detail, only: %i[show edit update destroy]

  # GET /master_setup/commission_details
  # GET /master_setup/commission_details.json
  def index
    @master_setup_commission_details = MasterSetup::CommissionDetail.all
  end

  # GET /master_setup/commission_details/1
  # GET /master_setup/commission_details/1.json
  def show
  end

  # GET /master_setup/commission_details/new
  def new
    @master_setup_commission_detail = MasterSetup::CommissionDetail.new
  end

  # GET /master_setup/commission_details/1/edit
  def edit
  end

  # POST /master_setup/commission_details
  # POST /master_setup/commission_details.json
  def create
    @master_setup_commission_detail = MasterSetup::CommissionDetail.new(master_setup_commission_detail_params)

    respond_to do |format|
      if @master_setup_commission_detail.save
        format.html { redirect_to @master_setup_commission_detail, notice: 'Commission detail was successfully created.' }
        format.json { render :show, status: :created, location: @master_setup_commission_detail }
      else
        format.html { render :new }
        format.json { render json: @master_setup_commission_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_setup/commission_details/1
  # PATCH/PUT /master_setup/commission_details/1.json
  def update
    respond_to do |format|
      if @master_setup_commission_detail.update(master_setup_commission_detail_params)
        format.html { redirect_to @master_setup_commission_detail, notice: 'Commission detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @master_setup_commission_detail }
      else
        format.html { render :edit }
        format.json { render json: @master_setup_commission_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_setup/commission_details/1
  # DELETE /master_setup/commission_details/1.json
  def destroy
    @master_setup_commission_detail.destroy
    respond_to do |format|
      format.html { redirect_to master_setup_commission_details_url, notice: 'Commission detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_master_setup_commission_detail
    @master_setup_commission_detail = MasterSetup::CommissionDetail.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def master_setup_commission_detail_params
    params.require(:master_setup_commission_detail).permit(:start_amount, :limit_amount, :commission_rate, :commission_amount, :master_setup_commission_info_id)
  end
end
