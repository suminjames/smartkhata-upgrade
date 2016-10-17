class BrokerProfilesController < ApplicationController
  before_action :set_broker_profile, only: [:show, :edit, :update, :destroy]

  # GET /broker_profiles
  # GET /broker_profiles.json
  def index
    @broker_profiles = BrokerProfile.all
  end

  # GET /broker_profiles/1
  # GET /broker_profiles/1.json
  def show
  end

  # GET /broker_profiles/new
  def new
    @broker_profile = BrokerProfile.new
  end

  # GET /broker_profiles/1/edit
  def edit
  end

  # POST /broker_profiles
  # POST /broker_profiles.json
  def create
    @broker_profile = BrokerProfile.new(broker_profile_params)

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

  # DELETE /broker_profiles/1
  # DELETE /broker_profiles/1.json
  def destroy
    @broker_profile.destroy
    respond_to do |format|
      format.html { redirect_to broker_profiles_url, notice: 'Broker profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_broker_profile
      @broker_profile = BrokerProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def broker_profile_params
      params.require(:broker_profile).permit(:broker_name, :broker_number, :address, :dp_code, :phone_number, :fax_number, :email, :pan_number, :profile_type, :locale)
    end
end
