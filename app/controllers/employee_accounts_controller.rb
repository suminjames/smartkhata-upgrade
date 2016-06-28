class EmployeeAccountsController < ApplicationController
  before_action :set_employee_account, only: [:show, :edit, :update, :destroy]

  # GET /employee_accounts
  # GET /employee_accounts.json
  def index
    authorize EmployeeAccount
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
    authorize @employee_account
  end

  # GET /employee_accounts/new
  def new
    @employee_account = EmployeeAccount.new
    authorize @employee_account
  end

  # GET /employee_accounts/1/edit
  def edit
    authorize @employee_account
    if params[:type] == 'ledger_access'
      @ledgers = Ledger.all.order(:name)
      render :edit_employee_ledger_association and return
    elsif params[:type] == 'menu_access'
      @menu_items = MenuItem.arrange
      render :edit_employee_menu_permission and return
    end
  end

  # POST /employee_accounts
  # POST /employee_accounts.json
  def create
    @employee_account = EmployeeAccount.new(employee_account_params)
    authorize @employee_account

    res = false
    ActiveRecord::Base.transaction do


      if @employee_account.save
        # Assign to Employee group
        @employee_account.assign_group("Employees")
        # and invite the user
        user = User.invite!(:email => @employee_account.email, role: :employee)
        @employee_account.user_id = user.id
        @employee_account.save
        res = true
      end
    end

    respond_to do |format|
      if res
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
    # This action has separate logic for basic employee account info update & employee account ledger_association update in place based on 'edit_type' params
    authorize @employee_account
    if params[:edit_type] == 'ledger_association'
      # TODO(sarojk): Throw error if no ledgers selected i.e., no ledger_association when has_access_to 'some'
      ActiveRecord::Base.transaction do

        EmployeeLedgerAssociation.delete_previous_associations_for(params[:id])

        respond_to do |format|
          if @employee_account.update(employee_account_ledger_association_params)
            format.html { redirect_to edit_employee_account_path(id: params[:id], type: 'ledger_access'), notice: 'Employee account ledger association was successfully updated.' }
            format.json { render :show, status: :ok, location: @employee_account }
          else
            format.html { render :edit }
            format.json { render json: @employee_account.errors, status: :unprocessable_entity }
          end
        end
      end
    elsif params[:edit_type] == 'menu_access'
      # get menu ids
      menu_ids = params[:employee_account][:menu_ids].map(&:to_i) if params[:employee_account][:menu_ids].present?
      ActiveRecord::Base.transaction do
        # delete previously set records
        # TODO(SUBAS) remove only the changed ones
        # create only the changed ones
        MenuPermission.delete_previous_permissions_for(@employee_account.user_id)
        menu_ids.each do |menu_id|
          MenuPermission.create!(user_id: @employee_account.user_id, menu_item_id: menu_id)
        end
      end
      redirect_to edit_employee_account_path(id: params[:id], type: 'menu_access'), notice: 'Employee account Menu access was successfully updated.'
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

  # POST/update_menu_access
  def update_menu_access
    authorize @employee_account



  end

  # DELETE /employee_accounts/1
  # DELETE /employee_accounts/1.json
  def destroy
    authorize @employee_account
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

  def employee_account_menu_params
    params.require(:employee_account).permit(:menu_permission => [])
  end

  def employee_account_ledger_association_params
    # TODO : Make more robust!
    if params[:employee_account][:has_access_to] == 'some'
      employee_ledger_associations_attributes = []
      params[:ledger_associations].each do |ledger_association|
        employee_ledger_associations_attributes << {:ledger_id => ledger_association}
      end
      # Update of 'has_many: employee_ledger_associations' taking place via employee_ledger_associations_attributes
      params[:employee_account][:employee_ledger_associations_attributes]= employee_ledger_associations_attributes
      params.require(:employee_account).permit(:has_access_to, :employee_ledger_associations_attributes => [:ledger_id])
    else
      params.require(:employee_account).permit(:has_access_to)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_account_params
    params.require(:employee_account).permit(
        :name,
        :address1,
        :address1_perm,
        :address2,
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

  def valid_email?(email)
    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    true if email.present? && (email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
  end
end
