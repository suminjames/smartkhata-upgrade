class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy]

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # TODO: http://stackoverflow.com/questions/22799631/postgresql-and-activerecord-where-regex-matching

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    # Instance variables to populate client and companies in the view
    @clients = ClientAccount.all
    @companies = IsinInfo.all

    # default landing action for '/share_transactions'
    if params[:show].blank? && params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to share_transactions_path(search_by: "client") }
      end
      return
    end

    # Populate (and route when needed) as per the params
    if params[:search_by] == "cancelled"
      @share_transactions = ShareTransaction.cancelled.order(:isin_info_id)
    elsif params[:search_by] == 'last_working_day'
      #TODO(sarojk): Implement a better way to find the last working day. Maybe something in application helper?
      date  = Time.now.to_date
      file = FileUpload::FILES[:floorsheet]
      fileupload = FileUpload.where(file: file).order("report_date desc").limit(1).first;
      if ( fileupload.present? )
        date = fileupload.report_date
      end

      respond_to do |format|
        format.html { redirect_to share_transactions_path(show: 'all', type: 'last_working_day', filter_by: 'date', date: ad_to_bs(date)), commit: 'Search' }
      end

    elsif params[:show] == 'all'
      if params[:filter_by] == 'date' && params[:date].present?
        date_bs = params[:date]
        if parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          @share_transactions = ShareTransaction.not_cancelled.find_by_date(date_ad).order(:isin_info_id)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present?  && params[:date][:to].present?
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = params[:date][:from]
        date_to_bs   = params[:date][:to]
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)
          @share_transactions = ShareTransaction.not_cancelled.find_by_date_range(date_from_ad, date_to_ad).order(:isin_info_id)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      else
        @share_transactions = ShareTransaction.not_cancelled.order(:isin_info_id)
      end
    elsif params[:search_by] == 'client' && params[:search_term]
      client_account_id = params[:search_term].to_i
      # @share_transactions to be returned if none of the following conditions are met
      @share_transactions = ShareTransaction.not_cancelled.where(client_account_id: client_account_id).order(:isin_info_id)
      if params[:filter_by] == 'date' && params[:date].present?
        date_bs = params[:date]
        if parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          @share_transactions = @share_transactions.find_by_date(date_ad)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present?  && params[:date][:to].present?
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = params[:date][:from]
        date_to_bs   = params[:date][:to]
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)
          @share_transactions = @share_transactions.find_by_date_range(date_from_ad, date_to_ad)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      end
      if params[:group_by] == 'company'
        @share_transactions = @share_transactions.includes(:isin_info).select("isin_infos.*").order("isin_infos.company").references(:isin_infos)
      end
    elsif params[:search_by] == 'company' && params[:search_term]
      isin_info_id = params[:search_term].to_i
      # @share_transactions to be returned if none of the following conditions are met
      @share_transactions = ShareTransaction.not_cancelled.where(isin_info_id: isin_info_id).order(:isin_info_id)

      if params[:filter_by] == 'date' && params[:date].present?
        date_bs = params[:date]
        if parsable_date? date_bs
          date_ad = bs_to_ad(date_bs)
          @share_transactions = @share_transactions.find_by_date(date_ad)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      elsif params[:filter_by] == 'date_range' && params[:date].present? && params[:date][:from].present?  && params[:date][:to].present?
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = params[:date][:from]
        date_to_bs   = params[:date][:to]
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)
          @share_transactions = @share_transactions.find_by_date_range(date_from_ad, date_to_ad)
        else
          @share_transactions = ''
          respond_to do |format|
            format.html { render :index }
            flash.now[:error] = 'Invalid date'
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      end
      if params[:group_by] == 'client'
        @share_transactions = @share_transactions.includes(:client_account).select("client_accounts.*").order("client_accounts.name").references(:client_accounts)
      end
    else
      # Return empty if none of the above arguments (of params) is met
      @share_transactions = []
    end
    @share_transactions = @share_transactions.page(params[:page]).per(20) unless @share_transactions.blank?
    # @share_transactions = @share_transactions.order(:isin_info_id) unless @share_transactions.blank?
  end

  # TODO MOVE THIS TO the index controller
  def deal_cancel
    if params[:id].present?
      @share_transaction = ShareTransaction.not_cancelled.find_by(id: params[:id].to_i)
      @voucher = @share_transaction.voucher
      @bill = @share_transaction.bill

      relevant_share_transactions = @bill.share_transactions.not_cancelled.where(isin_info_id: @share_transaction.isin_info_id)
      @dp_fee_adjustment = 0.0
      total_transaction_count = relevant_share_transactions.length





      ActiveRecord::Base.transaction do
        if total_transaction_count > 1
          dp_fee_adjustment = @share_transaction.dp_fee
          dp_fee_adjustment_per_transaction = dp_fee_adjustment / (total_transaction_count - 1.0)
          relevant_share_transactions.each do |transaction|
            unless transaction == @share_transaction
              transaction.dp_fee += dp_fee_adjustment_per_transaction
              transaction.save!
            end
          end
        end

        # now the bill will have atleast one deal cancelled transaction
        @bill.has_deal_cancelled!
        if ( @bill.net_amount - @share_transaction.net_amount ).abs <= 0.1
          @bill.balance_to_pay = 0
          @bill.net_amount = 0
          @bill.settled!
        else
          @bill.balance_to_pay -= (@share_transaction.net_amount - dp_fee_adjustment)
          @bill.net_amount -= (@share_transaction.net_amount - dp_fee_adjustment)
          @bill.partial!
        end
        @bill.save!

        # create a new voucher and add the bill reference to it
        @new_voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
        @new_voucher.bills_on_settlement << @bill

        description = "deal cancelled(#{@share_transaction.quantity}*#{@share_transaction.isin_info.isin}@#{@share_transaction.share_rate}) of Bill: (#{@bill.fy_code}-#{@bill.bill_number})"
        @voucher.particulars.each do |particular|
          reverse_accounts(particular,@new_voucher,description, dp_fee_adjustment)
        end
        @share_transaction.soft_delete
        @share_transaction.save!
      end
      flash.now[:notice] = 'Deal cancelled succesfully.'
      @share_transaction = nil
    end

    if params[:contract_no].present? && params[:transaction_type].present?
      # TODO make it work for enum
      case params[:transaction_type]
      when "sell"
        transaction_type = ShareTransaction.transaction_types[:sell]
      when "buy"
        transaction_type = ShareTransaction.transaction_types[:buy]
      else
        return
      end
      @share_transaction = ShareTransaction.not_cancelled.find_by(contract_no: params[:contract_no], transaction_type: transaction_type)
    end



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
    @share_transaction.update(share_transaction_params)
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
