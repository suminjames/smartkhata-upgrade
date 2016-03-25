class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy]

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    #Instance variable to populate (in select field) all clients in 'search by client' option
    @clients = ClientAccount.all
    @companies= IsinInfo.all

    # Cases
    # show=all
    # show=all  & group_by=company
    # show=all  & group_by=company & date=xx
    # show=all  & date=xx
    # show=all  & date[from]=xx & date[to]=yy
    # show=all  & group_by=company & date[from]=xx & date[to]=yy

    # search_by=client
    # search_by=client & client_id=z
    # search_by=client & client_id=z & group_by=company
    # search_by=client & client_id=z & group_by=company & date=xx
    # search_by=client & client_id=z & date=xx
    # search_by=client & client_id=z & date[from]=xx & date[to]=zz
    # search_by=client & client_id=z & group_by=company & date[from]=xx & date[to]=zz

    #default landing action for '/share_transactions'
    if params[:show].blank? && params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to share_transactions_path(show: "all") }
      end
      return
    end
    # Populate (and route when needed) as per the params
    if params[:show] == "all"
      @share_transactions = ShareTransaction.not_cancelled
    elsif params[:search_by] == "cancelled"
      @share_transactions = ShareTransaction.cancelled
    elsif params[:search_by] && params[:search_term] && params[:group_by]
      # TODO : Refactor
      client_account_id = params[:search_term].to_i
      # @share_transactions = ShareTransaction.where(client_account_id: client_account_id).order(:isin_info_id)
      # TODO: Order by isin_info isin(name) not id
      @share_transactions = ShareTransaction.not_cancelled.where(client_account_id: client_account_id).order(:isin_info_id)
    elsif params[:search_by] && params[:search_term]
      search_by = params[:search_by]
      search_term = params[:search_term]
      case search_by
      when 'client'
        client_account_id = search_term.to_i
        # TODO  move it to model
        @share_transactions = ShareTransaction.not_cancelled.where(client_account_id: client_account_id)
      when 'company'
        isin_info_id = search_term.to_i
        # TODO  move it to model
        @share_transactions = ShareTransaction.not_cancelled.where(isin_info_id: isin_info_id)
      else
        # If no matches for case  'search_by', return empty @share_transactions
        @share_transactions = []
      end
    else
      @share_transactions = []
    end
    # @share_transactions = @share_transactions.order(:isin_info_id).page(params[:page]).per(20) unless @share_transactions.blank?
    @share_transactions = @share_transactions.order(:isin_info_id) unless @share_transactions.blank?
  end

  # TODO MOVE THIS TO the index controller
  def deal_cancel
    if params[:id].present?
      @share_transaction = ShareTransaction.not_cancelled.find_by(id: params[:id].to_i)
      @voucher = @share_transaction.voucher
      @bill = @share_transaction.bill

      ActiveRecord::Base.transaction do
        if ( @bill.net_amount - @share_transaction.net_amount ).abs <= 0.1
          @bill.balance_to_pay = 0
          @bill.net_amount = 0
          @bill.cancelled!
        else
          @bill.balance_to_pay -= @share_transaction.net_amount
          @bill.net_amount -= @share_transaction.net_amount
          @bill.partial!
        end
        @bill.save!

        @new_voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
        description = "deal cancelled(#{@share_transaction.quantity}*#{@share_transaction.isin_info.isin}@#{@share_transaction.share_rate})"
        @voucher.particulars.each do |particular|
          reverse_accounts(particular,@new_voucher,description)
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
    respond_to do |format|
      if @share_transaction.update(share_transaction_params)
        format.html { redirect_to @share_transaction, notice: 'Share transaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @share_transaction }
      else
        format.html { render :edit }
        format.json { render json: @share_transaction.errors, status: :unprocessable_entity }
      end
    end
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
      params.fetch(:share_transaction, {})
    end
end
