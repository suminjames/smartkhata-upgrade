class EmployeeAccountsController < ApplicationController
  before_action :set_employee_account, only: [:show, :edit, :update, :destroy, :update_employee_access, :employee_access]

  before_action -> {authorize @employee_account}, only: [:show, :edit, :update, :destroy, :update_employee_access, :employee_access]
  before_action -> {authorize EmployeeAccount}, only: [:index, :new, :create, :combobox_ajax_filter]

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

    @selected_employee_for_combobox_in_arr = []

    if params[:show] == 'all'
      @employee_accounts = EmployeeAccount.all
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
        when 'name'
          @employee_accounts = EmployeeAccount.find_by_employee_id(search_term)
          @selected_employee_for_combobox_in_arr = [@employee_accounts[0]] if @employee_accounts.present?
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
    authorize @employee_account
  end

  # GET /employee_accounts/1/edit
  def edit
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
        @employee_account.save!
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
    if params[:edit_type] == 'create_or_update'
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

  def employee_access
    if params[:type] == 'ledger_access'
      @ledgers = Ledger.all.order(:name)
      render :edit_employee_ledger_association and return
    elsif params[:type] == 'branch_access'
      @menu_items = MenuItem.arrange
      render :edit_employee_branch_permission and return
    else
      @menu_items = MenuItem.arrange
      render :edit_employee_menu_permission and return
    end
  end

  # POST/update_menu_access
  def update_employee_access
    # This action has separate logic for basic employee account info update & employee account ledger_association update in place based on 'edit_type' params
    if params[:edit_type] == 'ledger_access'
      # TODO(sarojk): Throw error if no ledgers selected i.e., no ledger_association when has_access_to 'some'
      ActiveRecord::Base.transaction do

        EmployeeLedgerAssociation.delete_previous_associations_for(params[:id])

        respond_to do |format|
          if @employee_account.update(employee_account_ledger_association_params)
            format.html {redirect_to employee_accounts_employee_access_path(id: @employee_account.id, type: 'ledger_access'), notice: 'Employee account Branch access was successfully updated.'}
            format.json { render :show, status: :ok, location: @employee_account }
          else
            format.html { render :edit }
            format.json { render json: @employee_account.errors, status: :unprocessable_entity }
          end
        end
      end
    elsif params[:edit_type] == 'menu_access'
      user_role_id = params[:employee_account][:user_access_role_id] || nil
      ActiveRecord::Base.transaction do
        u = @employee_account.user
        u.user_access_role_id = user_role_id
        u.save!
      end
      redirect_to employee_accounts_employee_access_path(id: @employee_account.id, type: 'menu_access'), notice: 'Employee account Menu access was successfully updated.'
    elsif params[:edit_type] == 'branch_access'
      # get menu ids
      branch_ids = params[:employee_account][:branch_ids].map(&:to_i) if params[:employee_account][:branch_ids].present?
      ActiveRecord::Base.transaction do
        # # delete previously set records
        # # TODO(SUBAS) remove only the changed ones
        # # create only the changed ones
        BranchPermission.delete_previous_permissions_for(@employee_account.user_id)
        branch_ids.each do |branch_id|
          BranchPermission.create!(user_id: @employee_account.user_id, branch_id: branch_id)
        end
      end
      redirect_to employee_accounts_employee_access_path(id: @employee_account.id, type: 'branch_access'), notice: 'Employee account Branch access was successfully updated.'
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

  #
  # Entertains Ajax request made by combobox used in various views to populate employees.
  #
  def combobox_ajax_filter
    search_term = params[:q]
    employee_accounts = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      employee_accounts = EmployeeAccount.find_similar_to_term search_term
    end
    respond_to do |format|
      format.json { render json: employee_accounts, status: :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_employee_account
    @employee_account = EmployeeAccount.find(params[:id])
  end

  def authorize_employee_account
    authorize EmployeeAccount
  end

  def authorize_single_employee_account
    authorize @employee_account
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
