class MasterSetup::BrokerProfilesController < ApplicationController
  before_action :set_broker_profile, only: [:show, :edit, :update, :destroy]
  before_action :check_for_maximum_limit_reached, only: [:new, :create]

  before_action -> {authorize MasterSetup::BrokerProfile}, only: [:index, :new, :create]
  before_action -> {authorize @broker_profile}, only: [:show, :edit, :update, :destroy]

  # GET /broker_profiles
  # GET /broker_profiles.json
  def index
    @broker_profiles = MasterSetup::BrokerProfile.all
  end

  # GET /broker_profiles/1
  # GET /broker_profiles/1.json
  def show
  end

  # GET /broker_profiles/new
  def new
    locale = params[:locale]
    @broker_profile = MasterSetup::BrokerProfile.new
    if locale.present?
      @broker_profile.locale = locale
    end
  end

  # GET /broker_profiles/1/edit
  def edit
  end

  # POST /broker_profiles
  # POST /broker_profiles.json
  def create
    @broker_profile = MasterSetup::BrokerProfile.new(broker_profile_params)
    respond_to do |format|
      if @broker_profile.save
        format.html { redirect_to @broker_profile, notice: 'Broker profile was successfully created.' }
        format.json { render :show, status: :created, location: @broker_profile }
      else
        format.html { render :new }
        format.json { render json: @broker_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /broker_profiles/1
  # PATCH/PUT /broker_profiles/1.json
  def update
    respond_to do |format|
      if @broker_profile.update(broker_profile_params)
        format.html { redirect_to @broker_profile, notice: 'Broker profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @broker_profile }
      else
        format.html { render :edit }
        format.json { render json: @broker_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /broker_profiles/1
  # # DELETE /broker_profiles/1.json
  # def destroy
  #   @broker_profile.destroy
  #   respond_to do |format|
  #     format.html { redirect_to master_setup_broker_profiles_url, notice: 'Broker profile was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_broker_profile
    @broker_profile = MasterSetup::BrokerProfile.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def broker_profile_params
    params.require(:master_setup_broker_profile).permit(:broker_name, :broker_number, :address, :dp_code, :phone_number, :fax_number, :email, :pan_number, :locale)
  end

  def check_for_maximum_limit_reached
    if MasterSetup::BrokerProfile.has_maximum_records?
      redirect_to(
          {
              action: 'index'
          },
          alert: "Broker Profile number exceeded."
      ) and return
    end
  end
end