class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy]

  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper
  include ShareInventoryModule

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        select_options: {
            by_client_id: ShareTransaction.options_for_client_select,
            by_isin_id: ShareTransaction.options_for_isin_select
        },
        persistence_id: false
    ) or return
    items_per_page = params[:paginate] == 'false' ? ShareTransaction.by_date(params[:filterrific][:by_date]).count(:all) : 20
    @share_transactions= @filterrific.find.page(params[:page]).per(items_per_page)

    respond_to do |format|
      format.html
      format.js
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
  # GET /share_transactions
  # GET /share_transactions.json
  # def index
  #   # default landing action for '/share_transactions'
  #   if params[:show].blank? && params[:search_by].blank?
  #     respond_to do |format|
  #       format.html { redirect_to share_transactions_path(search_by: "client") }
  #     end
  #     return
  #   end
  #
  #   # Instance variable used by combobox in view to populate name
  #   if params[:search_by] == 'client'
  #     @clients = ClientAccount.all.order(:name)
  #   end
  #   # Instance variable used by combobox in view to populate name
  #   if params[:search_by] == 'company'
  #     @companies = IsinInfo.all.order(:isin)
  #   end
  #
  #   # Populate (and route when needed) as per the params
  #   if params[:search_by] == "cancelled"
  #     @share_transactions = ShareTransaction.cancelled.order(:isin_info_id)
  #     #  last floorsheet upload date
  #   elsif params[:search_by] == 'last_working_day'
  #     #TODO(sarojk): Implement a better way to find the last working day. Maybe something in application helper?
  #     date = Time.now.to_date
  #     file_type = FileUpload::file_types[:floorsheet]
  #     fileupload = FileUpload.where(file_type: file_type).order("report_date desc").limit(1).first;
  #     if (fileupload.present?)
  #       date = fileupload.report_date
  #     end
  #
  #     respond_to do |format|
  #       format.html { redirect_to share_transactions_path(show: 'all', type: 'last_working_day', filter_by: 'date', date: ad_to_bs_string(date)), commit: 'Search' }
  #     end
  #     #   to get only the floor sheet details no menus
  #     #   TODO (incorporate this to show like the others share transaction details)
  #   elsif params[:search_by] == 'floorsheet_date'
  #     date_ad = params[:report_date].to_date if params[:report_date].present?
  #     @share_transactions = ShareTransaction.find_by_date(date_ad).order(:isin_info_id)
  #     @total_amount = ShareTransaction.find_by_date(date_ad).sum(:share_amount)
  #     render 'floorsheet_data' and return
  #   elsif params[:show] == 'all'
  #     if params[:filter_by] == 'date' && params[:date].present?
  #       date_bs = params[:date]
  #       if parsable_date? date_bs
  #         date_ad = bs_to_ad(date_bs)
  #         @share_transactions = ShareTransaction.not_cancelled.find_by_date(date_ad).order(:isin_info_id)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present? && params[:date][:to].present?
  #       # The dates being entered are assumed to be BS dates, not AD dates
  #       date_from_bs = params[:date][:from]
  #       date_to_bs = params[:date][:to]
  #       # OPTIMIZE: Notify front-end of the particular date(s) invalidity
  #       if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
  #         date_from_ad = bs_to_ad(date_from_bs)
  #         date_to_ad = bs_to_ad(date_to_bs)
  #         @share_transactions = ShareTransaction.not_cancelled.find_by_date_range(date_from_ad, date_to_ad).order(:isin_info_id)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     else
  #       @share_transactions = ShareTransaction.not_cancelled.order(:isin_info_id)
  #     end
  #   elsif params[:search_by] == 'client' && params[:search_term]
  #     client_account_id = params[:search_term].to_i
  #     # @share_transactions to be returned if none of the following conditions are met
  #     @share_transactions = ShareTransaction.not_cancelled.where(client_account_id: client_account_id).order(:isin_info_id)
  #     if params[:filter_by] == 'date' && params[:date].present?
  #       date_bs = params[:date]
  #       if parsable_date? date_bs
  #         date_ad = bs_to_ad(date_bs)
  #         @share_transactions = @share_transactions.find_by_date(date_ad)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present? && params[:date][:to].present?
  #       # The dates being entered are assumed to be BS dates, not AD dates
  #       date_from_bs = params[:date][:from]
  #       date_to_bs = params[:date][:to]
  #       # OPTIMIZE: Notify front-end of the particular date(s) invalidity
  #       if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
  #         date_from_ad = bs_to_ad(date_from_bs)
  #         date_to_ad = bs_to_ad(date_to_bs)
  #         @share_transactions = @share_transactions.find_by_date_range(date_from_ad, date_to_ad)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     end
  #     if params[:group_by] == 'company'
  #       @share_transactions = @share_transactions.includes(:isin_info).select("isin_infos.*").order("isin_infos.company").references(:isin_infos)
  #     end
  #   elsif params[:search_by] == 'company' && params[:search_term]
  #     isin_info_id = params[:search_term].to_i
  #     # @share_transactions to be returned if none of the following conditions are met
  #     @share_transactions = ShareTransaction.not_cancelled.where(isin_info_id: isin_info_id).order(:isin_info_id)
  #
  #     if params[:filter_by] == 'date' && params[:date].present?
  #       date_bs = params[:date]
  #       if parsable_date? date_bs
  #         date_ad = bs_to_ad(date_bs)
  #         @share_transactions = @share_transactions.find_by_date(date_ad)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present? && params[:date][:to].present?
  #       # The dates being entered are assumed to be BS dates, not AD dates
  #       date_from_bs = params[:date][:from]
  #       date_to_bs = params[:date][:to]
  #       # OPTIMIZE: Notify front-end of the particular date(s) invalidity
  #       if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
  #         date_from_ad = bs_to_ad(date_from_bs)
  #         date_to_ad = bs_to_ad(date_to_bs)
  #         @share_transactions = @share_transactions.find_by_date_range(date_from_ad, date_to_ad)
  #       else
  #         @share_transactions = ''
  #         respond_to do |format|
  #           format.html { render :index }
  #           flash.now[:error] = 'Invalid date'
  #           format.json { render json: flash.now[:error], status: :unprocessable_entity }
  #         end
  #       end
  #     end
  #     if params[:group_by] == 'client'
  #       @share_transactions = @share_transactions.includes(:client_account).select("client_accounts.*").order("client_accounts.name").references(:client_accounts)
  #     end
  #   else
  #     # Return empty if none of the above arguments (of params) is met
  #     @share_transactions = []
  #   end
  #   @share_transactions = @share_transactions.page(params[:page]).per(20) unless @share_transactions.blank?
  #   # @share_transactions = @share_transactions.order(:isin_info_id) unless @share_transactions.blank?
  # end

  # TODO MOVE THIS TO the index controller
  def deal_cancel
    if params[:id].present?
      from_path = params[:from_path] || deal_cancel_share_transactions_path
      deal_cancel = DealCancelService.new(transaction_id: params[:id], broker_code: current_tenant.broker_code)
      deal_cancel.process
      @share_transaction = deal_cancel.share_transaction
      if deal_cancel.error_message.present?
        redirect_to from_path, alert: deal_cancel.error_message and return
      else
        @share_transaction = nil
        redirect_to from_path, notice: deal_cancel.info_message and return
      end
    end

    if params[:contract_no].present? && params[:transaction_type].present?
      case params[:transaction_type]
        when "selling"
          transaction_type = ShareTransaction.transaction_types[:selling]
        when "buying"
          transaction_type = ShareTransaction.transaction_types[:buying]
        else
          return
      end
      @is_searched = true
      @share_transaction = ShareTransaction.not_cancelled.find_by(contract_no: params[:contract_no], transaction_type: transaction_type)
    end
  end

  def pending_deal_cancel
    if params[:id].present?
      deal_cancel = DealCancelService.new(transaction_id: params[:id], approval_action: params[:approval_action], broker_code: current_tenant.broker_code)
      deal_cancel.process
      if deal_cancel.error_message.present?
        flash.now[:error] = deal_cancel.error_message
      else
        flash.now[:notice] = deal_cancel.info_message
      end
    end
    @share_transactions = ShareTransaction.deal_cancel_pending
  end

  # GET /share_transactions/1
  # GET /share_transactions/1.json
  def show
  end

  # GET /share_transactions/new
  def new
    @share_transaction = ShareTransaction.new
  end

  # GET /share_transactions/1/edit
  def edit
  end

  # POST /share_transactions
  # POST /share_transactions.json
  def create
    @share_transaction = ShareTransaction.new(share_transaction_params)

    respond_to do |format|
      if @share_transaction.save
        format.html { redirect_to @share_transaction, notice: 'Share transaction was successfully created.' }
        format.json { render :show, status: :created, location: @share_transaction }
      else
        format.html { render :new }
        format.json { render json: @share_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_transactions/1
  # PATCH/PUT /share_transactions/1.json
  def update
    # respond_to do |format|
    #   if @share_transaction.update(share_transaction_params)
    #     format.html { redirect_to @share_transaction, notice: 'Share transaction was successfully updated.' }
    #     format.json { render :index, status: :ok }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @share_transaction.errors, status: :unprocessable_entity }
    #   end
    # end
    @share_transaction.update_with_base_price(share_transaction_params)
  end

  # DELETE /share_transactions/1
  # DELETE /share_transactions/1.json
  def destroy
    @share_transaction.soft_delete
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_share_transaction
    @share_transaction = ShareTransaction.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def share_transaction_params
    params.require(:share_transaction).permit(:base_price)
  end
end
