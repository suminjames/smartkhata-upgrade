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

    # Instance variable used by combobox in view to populate name
    if params['search_by'] == 'ledger_name'
      @ledgers_for_combobox= Ledger.all.order(:name)
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
          ledger_id= search_term
          @ledgers = Ledger.find_by_ledger_id(ledger_id).includes(:client_account).order(:name).page(params[:page]).per(20)
        else
          # If no matches for case  'search_by', return empty @ledgers
          @ledgers = []
      end
    else
      @ledgers = []
    end
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

    @particulars,
        @total_credit,
        @total_debit,
        @closing_balance_sorted,
        @opening_balance_sorted = ledger_query.ledger_with_particulars

    if params[:format] == 'xlsx'
      # respond_to do |format|
      #   format.xlsx do; end
      # end
      report = Reports::Excelsheet::LedgersReport.new(@ledger, @particulars, params, current_tenant)
      if report.generated_successfully?
        send_file(report.path, type: report.type)
      else
        # This should be ideally an ajax notification!
        redirect_to ledgers_path, flash: { error: report.error }
      end
      return
    end
    @download_path_xlsx = ledger_path(@ledger, {format:'xlsx'}.merge(params))

    @particulars = @particulars.order(:name).page(params[:page]).per(20) unless @particulars.blank?
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

    @success = false
    if (@ledger.opening_balance >= 0)
      @success = true if @ledger.save
    else
      flash.now[:error] = "Dont act smart."
    end
    respond_to do |format|
      if @success
        format.html { redirect_to @ledger, notice: 'Ledger was successfully created.' }
        format.json { render :show, status: :created, location: @ledger }
      else
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


  # Get list of group members
  def group_members_ledgers
    authorize Ledger
    if params[:client_account_id]
      @client_account_id = params[:client_account_id].to_i
      @client_account = ClientAccount.find(@client_account_id)
      @ledgers = @client_account.get_group_members_ledgers_with_balance if @client_account || []
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
    params.require(:ledger).permit(:name, :opening_blnc, :group_id, :opening_balance_type, :vendor_account_id)
  end


  def get_ledger_ids_for_balance_transfer_params
    @ledger_ids = []
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @ledger_ids = params[:ledger_ids].map(&:to_i) if params[:ledger_ids].present?
  end
end
