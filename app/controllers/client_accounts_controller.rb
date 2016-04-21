  class ClientAccountsController < ApplicationController
  before_action :set_client_account, only: [:show, :edit, :update, :destroy]

  # GET /client_accounts
  # GET /client_accounts.json
  def index
    #default landing action for '/ledgers'
    # OPTIMIZE - Refactor
    if params[:search_by].blank? && params[:show].blank?
      respond_to do |format|
        format.html { redirect_to client_accounts_path(search_by: "name") }
      end
      return
    end

    if params[:show] == 'all'
      @client_accounts = ClientAccount.all
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'name'
        @client_accounts = ClientAccount.find_by_client_name(search_term)
      when 'boid'
        @client_accounts = ClientAccount.find_by_boid(search_term)
      else
        @client_accounts = []
      end
    else
      @client_accounts = []
    end
    @client_accounts = @client_accounts.order(:name).page(params[:page]).per(20) unless @client_accounts.blank?
  end

  # GET /client_accounts/1
  # GET /client_accounts/1.json
  def show
  end

  # GET /client_accounts/new
  def new
    @client_account = ClientAccount.new
  end

  # GET /client_accounts/1/edit
  def edit
    @from_path =  request.referer
  end

  # POST /client_accounts
  # POST /client_accounts.json
  def create

    @client_account = ClientAccount.new(client_account_params)
    respond_to do |format|
      if @client_account.save
        format.html { redirect_to @client_account, notice: 'Client account was successfully created.' }
        format.json { render :show, status: :created, location: @client_account }
      else
        format.html { render :new }
        format.json { render json: @client_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /client_accounts/1
  # PATCH/PUT /client_accounts/1.json
  def update
    from_path = params[:from_path]
    # abort(from_path.to_s)

    respond_to do |format|
      if @client_account.update(client_account_params)

        format.html {
          unless from_path.blank?
            redirect_to from_path, notice: 'Client account was successfully updated.'
          else
            redirect_to @client_account, notice: 'Client account was successfully updated.'
          end
        }
        format.json { render :show, status: :ok, location: @client_account }
      else
        format.html { render :edit }
        format.json { render json: @client_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_accounts/1
  # DELETE /client_accounts/1.json
  def destroy
    @client_account.destroy
    respond_to do |format|
      format.html { redirect_to client_accounts_url, notice: 'Client account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_account
      @client_account = ClientAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_account_params
      params.require(:client_account).permit(
        :boid,
        :nepse_code,
        :name,
        :address1 ,
        :address1_perm,
        :address2 ,
        :address2_perm,
        :address3,
        :address3_perm,
        :city,
        :city_perm,
        :state,
        :state_perm,
        :country,
        :country_perm,
        :phone,
        :phone_perm,
        :dob,
        :stmt_cycle_code,
        :email,
        :father_mother,
        :citizen_passport,
        :granfather_father_inlaw,
        :husband_spouse,
        :citizen_passport_date,
        :citizen_passport_district,
        :pan_no,
        :bank_name,
        :bank_account,
        :bank_address,
        :company_name,
        :company_id,
        :client_type
        )
    end
end
