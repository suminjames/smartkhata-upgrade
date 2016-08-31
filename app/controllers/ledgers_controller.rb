class LedgersController < ApplicationController
  before_action :set_ledger, only: [:show, :edit, :update, :destroy]
  before_action :get_ledger_ids_for_balance_transfer_params, only: [:transfer_group_member_balance]

  # GET /ledgers
  # GET /ledgers.json
  def index
    authorize Ledger
    #default landing action for '/ledgers'
    # OPTIMIZE - Refactor
    if params[:show].blank? && params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to ledgers_path(search_by: "ledger_name") }
      end
      return
    end

    if params[:show] == "all"
      @ledgers = Ledger.all.includes(:client_account).order(:name).page(params[:page]).per(20)
    elsif params[:show] == "all_client"
      @ledgers = Ledger.find_all_client_ledgers.includes(:client_account).order(:name).page(params[:page]).per(20)
    elsif params[:show] == "all_internal"
      @ledgers = Ledger.find_all_internal_ledgers.includes(:client_account).order(:name).page(params[:page]).per(20)
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
        when 'ledger_name'
          ledger_id = search_term
          @ledgers = Ledger.find_by_ledger_id(ledger_id).includes(:client_account).order(:name).page(params[:page]).per(20)
        else
          # If no matches for case  'search_by', return empty @ledgers
          @ledgers = []
      end
    else
      @ledgers = []
    end
    @selected_ledger_for_combobox_in_arr = @ledgers
    # Order ledgers as per ledger_name and not updated_at(which is the metric for default ordering)
    # TODO chain .decorate function
    # @ledgers = @ledgers.includes(:client_account).order(:name).page(params[:page]).per(20) unless @ledgers.blank?
  end

  # GET /ledgers/1
  # GET /ledgers/1.json
  def show
    authorize @ledger
    @back_path = request.referer || ledgers_path
    ledger_query = Ledgers::Query.new(params, @ledger)

    if params[:format] == 'xlsx'
      @particulars = ledger_query.ledger_with_particulars(true)[0]
      @particulars = @particulars.reject &:hide_for_client if params[:for_client] == "1" # no reject! ?
      report = Reports::Excelsheet::LedgersReport.new(@ledger, @particulars, params, current_tenant)
      if report.generated_successfully?
        # send_file(report.path, type: report.type)
        send_data(report.file, type: report.type, filename: report.filename)
        report.clear
      else
        # This should be ideally an ajax notification!
        redirect_to ledgers_path, flash: { error: report.error }
      end
      return
    end

    @particulars,
        @total_credit,
        @total_debit,
        @closing_balance_sorted,
        @opening_balance_sorted = ledger_query.ledger_with_particulars

    @download_path_xlsx =  ledger_path(@ledger, {format:'xlsx'}.merge(params))
    @download_path_xlsx_client =  ledger_path(@ledger, {format:'xlsx', for_client: 1}.merge(params))

    # @particulars = @particulars.order(:name).page(params[:page]).per(20) unless @particulars.blank?
    unless ledger_query.error_message.blank?
      respond_to do |format|
        flash.now[:error] = ledger_query.error_message
        format.html { render :show }
        format.json { render json: flash.now[:error], status: :unprocessable_entity }
      end
    end
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
    @ledger.ledger_balances << LedgerBalance.new
    authorize @ledger
  end

  # GET /ledgers/1/edit
  def edit
    authorize @ledger
    @can_edit_balance = (@ledger.particulars.count <= 0) && (@ledger.opening_balance == 0.0)
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)
    authorize @ledger
    @valid = false
    @success = false
    total_balance = 0.0

    branch_ids = []

    @ledger.ledger_balances.each do |balance|
      if balance.opening_balance >=0
        if branch_ids.include?(balance.branch_id)
          flash.now[:error] = "Please include a entry for one branch"
          @valid = false
          break
        end
        @valid = true
        branch_ids << balance.branch_id
        total_balance += balance.opening_balance_type == "0" ? balance.opening_balance : ( balance.opening_balance * -1 )
        next
      end
      @valid = false
      flash.now[:error] = "Please dont include a negative amount"
      break
    end

    unless @ledger.group_id.present?
      @ledger.errors.add(:group_id, "can't be empty")
      @valid = false
    end

    if @valid
      @ledger.ledger_balances << LedgerBalance.new(branch_id: nil, opening_balance: total_balance)
      @success = true if @ledger.save
    end

    respond_to do |format|
      if @success
        format.html { redirect_to @ledger, notice: 'Ledger was successfully created.' }
        format.json { render :show, status: :created, location: @ledger }
      else
        @ledger.ledger_balances = @ledger.ledger_balances[0..-2] if @valid
        format.html { render :new }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledgers/1
  # PATCH/PUT /ledgers/1.json
  def update
    authorize @ledger
    respond_to do |format|
      if @ledger.update_custom(ledger_params)
        format.html { redirect_to @ledger, notice: 'Ledger was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger }
      else
        format.html { render :edit }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledgers/1
  # DELETE /ledgers/1.json
  def destroy
    authorize @ledger
    @ledger.destroy
    respond_to do |format|
      format.html { redirect_to ledgers_url, notice: 'Ledger was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #
  # Entertains Ajax request made by combobox used in various views to populate ledgers.
  #
  def combobox_ajax_filter
    search_term = params[:q]
    ledgers = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      ledgers = Ledger.find_similar_to_term search_term
    end
    respond_to do |format|
      format.json { render json: ledgers, status: :ok }
    end
  end

  def daybook
    authorize Ledger
    @back_path = request.referer || ledgers_path
    @ledger = Ledger.find(8)
    @daybook_ledgers = Ledger.daybook_ledgers
    ledger_query = Ledgers::DaybookQuery.new(params)

    @particulars,
        @total_credit,
        @total_debit,
        @closing_balance_sorted,
        @opening_balance_sorted = ledger_query.ledger_with_particulars

    respond_to do |format|
      format.html
      format.js
    end
  end

  def cashbook
    authorize Ledger
    @back_path = request.referer || ledgers_path
    @ledger = Ledger.find(8)
    @cashbook_ledgers = Ledger.cashbook_ledgers
    ledger_query = Ledgers::CashbookQuery.new(params)

    @particulars,
        @total_credit,
        @total_debit,
        @closing_balance_sorted,
        @opening_balance_sorted = ledger_query.ledger_with_particulars

    respond_to do |format|
      format.html
      format.js
    end
  end


  # Get list of group members
  def group_members_ledgers
    authorize Ledger
    if params[:client_account_id]
      @client_account_id = params[:client_account_id].to_i
      @client_account = ClientAccount.find(@client_account_id)
      @ledgers = (@client_account.get_group_members_ledgers_with_balance if @client_account) || []
    end
    @client_with_group_members = ClientAccount.having_group_members.uniq
  end

  def transfer_group_member_balance
    authorize Ledger
    client_account = ClientAccount.find(@client_account_id)
    @back_path = request.referer || group_member_ledgers_path

    if @ledger_ids.size <= 0 || client_account.blank?
      redirect_to @back_path, :flash => {:error => 'No Ledgers were Selected'} and return
    end

    ledger_list = Ledger.get_ledger_by_ids(fy_code: get_fy_code, ledger_ids: @ledger_ids)
    group_member_ledger_ids = client_account.get_group_members_ledger_ids

    # make sure all id in ledger_ids are in group_memger_ledger_ids
    unless (@ledger_ids - group_member_ledger_ids).empty?
      redirect_to @back_path, :flash => {:error => 'Invalid Ledgers'} and return
    end

    group_leader_ledger = client_account.ledger
    net_balance = 0.00

    # transfer the ledger balances to the group leader
    ActiveRecord::Base.transaction do
      # update description
      description = "Balance Transferred to #{client_account.name}"
      # update ledgers value
      voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now), desc: description, voucher_status: :complete)

      # update each ledgers
      ledger_list.each do |ledger|
        _closing_balance = ledger.closing_balance
        net_balance += _closing_balance
        process_accounts(ledger, voucher, _closing_balance < 0, _closing_balance.abs, description, session[:user_selected_branch_id], Time.now.to_date)
      end

      process_accounts(group_leader_ledger, voucher, net_balance >= 0, net_balance.abs, description, session[:user_selected_branch_id], Time.now.to_date)
    end

    redirect_to group_member_ledgers_path, :flash => {:info => 'Successfully Transferred'} and return
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ledger
    @ledger = Ledger.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ledger_params
    params.require(:ledger).permit(:name, :opening_blnc, :group_id, :opening_balance_type, :vendor_account_id, ledger_balances_attributes: [:opening_balance, :opening_balance_type, :branch_id])
  end


  def get_ledger_ids_for_balance_transfer_params
    @ledger_ids = []
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @ledger_ids = params[:ledger_ids].map(&:to_i) if params[:ledger_ids].present?
  end
end
