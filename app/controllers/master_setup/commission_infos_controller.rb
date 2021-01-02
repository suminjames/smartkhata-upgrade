class MasterSetup::CommissionInfosController < ApplicationController
  before_action :set_master_setup_commission_info, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @master_setup_commission_info}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize MasterSetup::CommissionInfo}, only: [:index, :new, :create]

  # GET /master_setup/commission_infos
  # GET /master_setup/commission_infos.json
  def index
    @commission_infos = MasterSetup::CommissionInfo.order(group: :asc, start_date: :asc).all
  end

  # GET /master_setup/commission_infos/1
  # GET /master_setup/commission_infos/1.json
  def show
  end

  # GET /master_setup/commission_infos/new
  def new
    @master_setup_commission_info = MasterSetup::CommissionInfo.new
    @master_setup_commission_info.commission_details = [MasterSetup::CommissionDetail.new]
  end

  # GET /master_setup/commission_infos/1/edit
  def edit
  end

  # POST /master_setup/commission_infos
  # POST /master_setup/commission_infos.json
  def create
    @master_setup_commission_info = MasterSetup::CommissionInfo.new(master_setup_commission_info_params)

    respond_to do |format|
      if @master_setup_commission_info.save
        format.html { redirect_to @master_setup_commission_info, notice: 'Commission info was successfully created.' }
        format.json { render :show, status: :created, location: @master_setup_commission_info }
      else
        format.html { render :new }
        format.json { render json: @master_setup_commission_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_setup/commission_infos/1
  # PATCH/PUT /master_setup/commission_infos/1.json
  def update
    respond_to do |format|
      if @master_setup_commission_info.update(master_setup_commission_info_params)
        format.html { redirect_to @master_setup_commission_info, notice: 'Commission info was successfully updated.' }
        format.json { render :show, status: :ok, location: @master_setup_commission_info }
      else
        format.html { render :edit }
        format.json { render json: @master_setup_commission_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_setup/commission_infos/1
  # DELETE /master_setup/commission_infos/1.json
  def destroy
    @master_setup_commission_info.destroy
    respond_to do |format|
      format.html { redirect_to master_setup_commission_infos_url, notice: 'Commission info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master_setup_commission_info
      @master_setup_commission_info = MasterSetup::CommissionInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_setup_commission_info_params
      params.require(:master_setup_commission_info).permit(:start_date, :end_date, :start_date_bs, :end_date_bs, :group, :nepse_commission_rate, :sebo_rate, commission_details_attributes: [:id, :start_amount,:limit_amount, :commission_rate, :commission_amount])
    end
end
