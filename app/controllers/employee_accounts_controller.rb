class EmployeeAccountsController < ApplicationController
  before_action :set_employee_account, only: [:show, :edit, :update, :destroy]

  # GET /employee_accounts
  # GET /employee_accounts.json
   def index
    #default landing action for '/ledgers'
    # OPTIMIZE - Refactor
    if params[:search_by].blank? && params[:show].blank?
      respond_to do |format|
        format.html { redirect_to employee_accounts_path(search_by: "name") }
      end
      return
    end

    # Instance variable used by combobox in view to populate name
    if params[:search_by] == 'name'
      @employees_for_combobox = EmployeeAccount.all.order(:name)
    end

    if params[:show] == 'all'
      @employee_accounts = EmployeeAccount.all
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'name'
        @employee_accounts = EmployeeAccount.find_by_employee_id(search_term)
      else
        @employee_accounts = []
      end
    else
      @employee_accounts = []
    end
    @employee_accounts = @employee_accounts.order(:name).page(params[:page]).per(20) unless @employee_accounts.blank?
  end

  # GET /employee_accounts/1
  # GET /employee_accounts/1.json
  def show
  end

  # GET /employee_accounts/new
  def new
    @employee_account = EmployeeAccount.new
  end

  # GET /employee_accounts/1/edit
  def edit
    @ledgers = Ledger.all.order(client_code: :desc)
  end

  # POST /employee_accounts
  # POST /employee_accounts.json
  def create
    @employee_account = EmployeeAccount.new(employee_account_params)

    respond_to do |format|
      if @employee_account.save
        format.html { redirect_to @employee_account, notice: 'Employee account was successfully created.' }
        format.json { render :show, status: :created, location: @employee_account }
      else
        format.html { render :new }
        format.json { render json: @employee_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_accounts/1
  # PATCH/PUT /employee_accounts/1.json
  def update
    # Separate logic for basic employee account info update & employee account client_association update in place based on a hidden 'edit_type' field in the forms
    if params[:edit_type] == 'client_association'
      # TODO: Throw error if no ledgers selected i.e., no client_association when has_access_to 'some'
      EmployeeClientAssociation.delete_previous_associations_for(params[:id])
      respond_to do |format|
        if @employee_account.update(employee_account_client_association_params)
          format.html { redirect_to edit_employee_account_path(id: params[:id], type: 'client_access'), notice: 'Employee account client association was successfully updated.' }
          format.json { render :show, status: :ok, location: @employee_account }
        else
          format.html { render :edit }
          format.json { render json: @employee_account.errors, status: :unprocessable_entity }
        end
      end
    elsif params[:edit_type] == 'create_or_update'
      respond_to do |format|
        if @employee_account.update(employee_account_params)
          format.html { redirect_to @employee_account, notice: 'Employee account was successfully updated.' }
          format.json { render :show, status: :ok, location: @employee_account }
        else
          format.html { render :edit }
          format.json { render json: @employee_account.errors, status: :unprocessable_entity }
        end

      end
    end
  end

    # DELETE /employee_accounts/1
    # DELETE /employee_accounts/1.json
    def destroy
      @employee_account.destroy
      respond_to do |format|
        format.html { redirect_to employee_accounts_url, notice: 'Employee account was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee_account
      @employee_account = EmployeeAccount.find(params[:id])
    end

    def employee_account_client_association_params
      # TODO : Make more robust?
      if params[:employee_account][:has_access_to] == ('some')
        employee_client_associations_attributes = []
        params[:client_associations].each do |client_association|
          employee_client_associations_attributes <<  {:client_account_id => client_association}
        end
        params[:employee_account][:employee_client_associations_attributes]= employee_client_associations_attributes
        params.require(:employee_account).permit(:has_access_to, :employee_client_associations_attributes => [:client_account_id])
      else
        params.require(:employee_account).permit(:has_access_to)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
  def employee_account_params
    params.require(:employee_account).permit(
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
        :has_access_to
    )
  end
end
