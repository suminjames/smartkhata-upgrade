class LedgersController < ApplicationController
  before_action :set_ledger, only: [:show, :edit, :update, :destroy]
  before_action :get_ledger_ids_for_balance_transfer_params, only: [:transfer_group_member_balance]

  before_action -> {authorize Ledger}, only: [:index, :new, :create, :combobox_ajax_filter, :daybook, :cashbook, :group_members_ledgers, :transfer_group_member_balance, :show_all]
  before_action -> {authorize @ledger}, only: [:show, :edit, :update, :destroy]

  # GET /ledgers
  # GET /ledgers.json
  def index
    #default landing action for '/ledgers'
      @filterrific = initialize_filterrific(
          Ledger,
          params[:filterrific],
          select_options: {
            by_ledger_id: Ledger.options_for_ledger_select(params[:filterrific]),
            by_ledger_type: Ledger.options_for_ledger_type,
          },
          persistence_id: false
      ) or return
      items_per_page = params[:paginate] == 'false' ? Ledger.count : 20
      @ledgers = @filterrific.find.includes(:client_account).page(params[:page]).per(items_per_page)
      respond_to do |format|
        format.html
        format.js
      end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /ledgers/1
  # GET /ledgers/1.json
  def show
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

    # @download_path_xlsx =  ledger_path(@ledger, {format:'xlsx'}.merge(params))
    # @download_path_xlsx_client =  ledger_path(@ledger, {format:'xlsx', for_client: 1}.merge(params))
    @download_path_xlsx =  ledger_path(@ledger, request.query_parameters.merge(format: 'xlsx'))
    @download_path_xlsx_client =  ledger_path(@ledger, request.query_parameters.merge(format: 'xlsx', for_client: 1))

    # @particulars = @particulars.order(:name).page(params[:page]).per(20) unless @particulars.blank?
    unless ledger_query.error_message.blank?
      respond_to do |format|
        flash.now[:error] = ledger_query.error_message
        format.html { render :show }
        format.json { render json: flash.now[:error], status: :unprocessable_entity }
      end
    end
  end

  def show_all
    @date_bs = params[:date_bs]
    if params[:date_bs].present?
      @particulars = Particular.includes(:voucher).where(date_bs: @date_bs).where('vouchers.voucher_type IN (1,2,4,5,6,7,8)').where('vouchers.created_at <= ?','2016-11-01').references(:vouchers).order(ledger_id: :desc)
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
    @can_edit_balance = @ledger.has_editable_balance?
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
    @can_edit_balance = @ledger.has_editable_balance?
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
    search_type = params[:search_type]
    ledgers = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      ledgers = Ledger.find_similar_to_term(search_term, search_type)
    end
    respond_to do |format|
      format.json { render json: ledgers, status: :ok }
    end
  end

  def daybook
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
    if params[:client_account_id]
      @client_account_id = params[:client_account_id].to_i
      @client_account = ClientAccount.find(@client_account_id)
      @ledgers = (@client_account.get_group_members_ledgers_with_balance if @client_account) || []
    end
    @client_with_group_members = ClientAccount.having_group_members.uniq
  end

  def transfer_group_member_balance
    client_account = ClientAccount.find(@client_account_id)
    @back_path = request.referer || group_member_ledgers_path

    if @ledger_ids.size <= 0 || client_account.blank?
      redirect_to @back_path, :flash => {:error => 'No Ledgers were Selected'} and return
    end

    ledger_list = Ledger.where(id: @ledger_ids)
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
        # dont consider the 0 balance ledger
        if ledger.closing_balance.abs > 0.01
          net_balance += _closing_balance
          process_accounts(ledger, voucher, _closing_balance < 0, _closing_balance.abs, description, session[:user_selected_branch_id], Time.now.to_date)
        end
      end

      process_accounts(group_leader_ledger, voucher, net_balance >= 0, net_balance.abs, description, session[:user_selected_branch_id], Time.now.to_date)
      raise ActiveRecord::Rollback if net_balance == 0.0
    end

    # also redirect to same path
    if net_balance == 0.0
      redirect_to @back_path, :flash => {:error => 'The balance to transfer is 0'} and return
    end
    redirect_to group_member_ledgers_path, notice: 'Successfully Transferred' and return
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ledger
    @ledger = Ledger.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ledger_params
    params.require(:ledger).permit(:name, :opening_blnc, :group_id, :opening_balance_type, :vendor_account_id, ledger_balances_attributes: [:opening_balance, :opening_balance_type, :branch_id, :id])
  end


  def get_ledger_ids_for_balance_transfer_params
    @ledger_ids = []
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @ledger_ids = params[:ledger_ids].map(&:to_i) if params[:ledger_ids].present?
  end
end
