class LedgersController < ApplicationController
  before_action :set_ledger, only: [:show, :edit, :update, :destroy]
  before_action :get_ledger_ids_for_balance_transfer_params, only: [:transfer_group_member_balance]

  # GET /ledgers
  # GET /ledgers.json
  def index
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
      @ledgers = Ledger.all.includes(:client_account)
    elsif params[:show] == "all_client"
      @ledgers = Ledger.includes(:client_account).find_all_client_ledgers
    elsif params[:show] == "all_internal"
      @ledgers = Ledger.includes(:client_account).find_all_internal_ledgers
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'ledger_name'
        ledger_id= search_term
        @ledgers = Ledger.includes(:client_account).find_by_ledger_id(ledger_id)
      else
        # If no matches for case  'search_by', return empty @ledgers
        @ledgers = ''
      end
    else
      @ledgers = ''
    end
    # Order ledgers as per ledger_name and not updated_at(which is the metric for default ordering)
    # TODO chain .decorate function
    @ledgers = @ledgers.order(:name).page(params[:page]).per(20) unless @ledgers.blank?
  end

  # GET /ledgers/1
  # GET /ledgers/1.json
  def show
    @back_path =  request.referer || ledgers_path
    if params[:show] == "all"
      @particulars = @ledger.particulars.complete.order("id ASC")
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
        when 'date_range'
          # The dates being entered are assumed to be BS dates, not AD dates
          date_from_bs = search_term['date_from']
          date_to_bs   = search_term['date_to']
          # OPTIMIZE: Notify front-end of the particular date(s) invalidity
          if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
            date_from_ad = bs_to_ad(date_from_bs)
            date_to_ad = bs_to_ad(date_to_bs)
            @particulars = @ledger.particulars.complete.find_by_date_range(date_from_ad, date_to_ad).order("id ASC")
            @total_credit = @ledger.particulars.complete.find_by_date_range(date_from_ad, date_to_ad).cr.sum(:amount)
            @total_debit = @ledger.particulars.complete.find_by_date_range(date_from_ad, date_to_ad).dr.sum(:amount)
            first = @particulars.first
            last = @particulars.last

            @closing_blnc_sorted = last.running_blnc

            if first.dr?
              @opening_blnc_sorted = first.running_blnc - first.amount
            else
              @opening_blnc_sorted = first.running_blnc + first.amount
            end


          else
            @particulars = ''
            respond_to do |format|
              flash.now[:error] = 'Invalid date(s)'
              format.html { render :show }
              format.json { render json: flash.now[:error], status: :unprocessable_entity }
            end
          end
        else
          @particulars = ''
      end

    elsif params[:search_by]
      @particulars = ''
    else
      @particulars = @ledger.particulars.complete.order("id ASC")
    end

    @particulars = @particulars.order(:name).page(params[:page]).per(20) unless @particulars.blank?
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
  end

  # GET /ledgers/1/edit
  def edit
    @can_edit_balance =  ( @ledger.particulars.count <= 0 ) && (@ledger.opening_blnc == 0.0)
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)
    @success = false
    if (@ledger.opening_blnc >= 0)
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


  # Get list of group members
  def group_members_ledgers
    if params[:client_account_id]
      @client_account_id = params[:client_account_id].to_i
      @client_account = ClientAccount.find(@client_account_id)
      @ledgers = @client_account.get_group_members_ledgers if @client_account || []
    end
    @client_with_group_members = ClientAccount.having_group_members
  end

  def transfer_group_member_balance
    client_account = ClientAccount.find(@client_account_id)
    @back_path =  request.referer || group_member_ledgers_path

    if @ledger_ids.size <= 0 || client_account.blank?
      redirect_to @back_path, :flash => { :error => 'No Ledgers were Selected' } and return
    end

    ledger_list = Ledger.get_ledger_by_ids(fy_code: get_fy_code, ledger_ids: @ledger_ids)
    group_member_ledger_ids = client_account.get_group_members_ledger_ids

    # make sure all id in ledger_ids are in group_memger_ledger_ids
    unless (@ledger_ids - group_member_ledger_ids).empty?
      redirect_to @back_path, :flash => { :error => 'Invalid Ledgers' } and return
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
        _closing_balance = ledger.closing_blnc
        net_balance += _closing_balance

        process_accounts(ledger, voucher, _closing_balance < 0 , _closing_balance.abs, description)
      end

      process_accounts(group_leader_ledger, voucher, net_balance >= 0 , net_balance.abs, description)
    end

    redirect_to group_member_ledgers_path, :flash => { :info => 'Successfully Transferred' } and return
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger
      @ledger = Ledger.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_params
      params.require(:ledger).permit(:name, :opening_blnc, :group_id, :opening_blnc_type, :vendor_account_id)
    end


  def get_ledger_ids_for_balance_transfer_params
    @ledger_ids = []
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    @ledger_ids = params[:ledger_ids].map(&:to_i) if params[:ledger_ids].present?
  end
end
