class ClientAccountsController < ApplicationController
  before_action :set_client_account, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @client_account}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize ClientAccount}, only: [:index, :new, :create, :combobox_ajax_filter]

  # GET /client_accounts
  # GET /client_accounts.json
  def index
    # Incorporate selected branch from session into filterrific in each request.
    params[:filterrific] ||= {}
    params[:filterrific].merge!({by_selected_session_branch_id: UserSession.selected_branch_id})
    @filterrific = initialize_filterrific(
        ClientAccount,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            client_filter: ClientAccount.options_for_client_filter,
        },
        persistence_id: false
    ) or return

    @selected_ledger_for_combobox_in_arr = @ledgers

    items_per_page = params[:paginate] == 'false' || ['xlsx', 'pdf'].include?(params[:format]) ? ClientAccount.all.count : 20
    @client_accounts = params[:paginate] == 'false' ?  @filterrific.find : @filterrific.find.page(params[:page]).per(items_per_page)

    @download_path_xlsx = client_accounts_path({format:'xlsx'}.merge params)
    @download_path_pdf = client_accounts_path({format:'pdf'}.merge params)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Reports::Pdf::ClientAccountsReport.new(@client_accounts, params[:filterrific], current_tenant)
        send_data pdf.render, filename:  "ClientAccountRegister#{ad_to_bs(Date.today)}.pdf", type: 'application/pdf'
      end
      format.xlsx do
        report = Reports::Excelsheet::ClientAccountsReport.new(@client_accounts, params[:filterrific], current_tenant)
        if report.generated_successfully?
          send_data report.file, type: report.type, filename: report.filename
          report.clear
        else
          redirect_to client_accounts_path, flash: { error: report.error }
        end
      end
    end
      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /client_accounts/1
  # GET /client_accounts/1.json
  def show
  end

  # GET /client_accounts/new
  def new
    @client_account = ClientAccount.new
    authorize @client_account
  end

  # GET /client_accounts/1/edit
  def edit
    @from_path = request.referer
  end

  # POST /client_accounts
  # POST /client_accounts.json
  def create
    @client_account = ClientAccount.new(client_account_params)
    authorize @client_account
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


  #
  # Entertains Ajax request made by combobox used in various views to populate clients.
  #
  def combobox_ajax_filter
    search_term = params[:q]
    selected_session_branch_id = UserSession.selected_branch_id
    client_accounts = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      client_accounts = ClientAccount.find_similar_to_term(search_term, selected_session_branch_id)
    end
    respond_to do |format|
      format.json { render json: client_accounts, status: :ok }
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
        :client_type,
        :referrer_name,
        :group_leader_id,
        :profession_code,
        :branch_id,
        :mobile_number
    )
  end
end
