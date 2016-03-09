class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy]

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    @share_transactions = ShareTransaction.all
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
    @share_transaction.destroy
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
