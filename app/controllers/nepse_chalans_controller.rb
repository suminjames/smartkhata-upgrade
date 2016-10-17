class NepseChalansController < ApplicationController
  before_action :set_nepse_chalan, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @nepse_chalan}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize NepseChalan}, only: [:index, :new, :create]

  # GET /nepse_chalans
  # GET /nepse_chalans.json
  def index
    @nepse_chalans = NepseChalan.all
  end

  # GET /nepse_chalans/1
  # GET /nepse_chalans/1.json
  def show
    @share_transactions = @nepse_chalan.share_transactions
  end

  # GET /nepse_chalans/new
  def new
    @nepse_chalan = NepseChalan.new
    search_by = params[:search_by]
    search_term = params[:search_term]
    @bank_ledger_list = BankAccount.by_branch_id.all.uniq.collect(&:ledger)
    default_bank_payment = BankAccount.by_branch_id.where(:default_for_payment => true).first
    @default_ledger_id = default_bank_payment.ledger.id if default_bank_payment.present?

    case search_by
      when 'date_range'
        # The dates being entered are assumed to be BS dates, not AD dates
        date_from_bs = search_term['date_from']
        date_to_bs = search_term['date_to']
        # OPTIMIZE: Notify front-end of the particular date(s) invalidity
        if parsable_date?(date_from_bs) && parsable_date?(date_to_bs)
          date_from_ad = bs_to_ad(date_from_bs)
          date_to_ad = bs_to_ad(date_to_bs)
          @share_transactions = ShareTransaction.buying.without_chalan.find_by_date_range(date_from_ad, date_to_ad)
        else
          @share_transactions = []
          respond_to do |format|
            flash.now[:error] = 'Invalid date(s)'
            format.html { render :new }
            format.json { render json: flash.now[:error], status: :unprocessable_entity }
          end
        end
      else
        # If no matches for case 'search_by', return empty @bills
        @share_transactions = []
    end
  end


  # GET /nepse_chalans/1/edit
  def edit
  end

  # POST /nepse_chalans
  # POST /nepse_chalans.json
  def create
    selected_transaction_ids = params[:nepse_share_selection].map(&:to_i) if params[:nepse_share_selection].present?
    share_transactions = []
    bank_ledger_id = params[:bank_ledger_id]
    nepse_settlement_id = params[:settlement_id]

    bank_ledger = Ledger.find_by(id: bank_ledger_id)

    if !bank_ledger.present?
      redirect_to new_nepse_chalan_path, flash: {error: 'Bank Ledger is not selected'} and return
    end

    if selected_transaction_ids.nil?
      redirect_to new_nepse_chalan_path, flash: {error: 'Try again'} and return
    end

    if UserSession.selected_fy_code != get_fy_code
      redirect_to @back_path, :flash => {:error => 'Please select the current fiscal year'} and return
    end

    share_transactions = ShareTransaction.buying.where(id: selected_transaction_ids)
    if share_transactions.size < 1
      redirect_to new_nepse_chalan_path, flash: {error: 'No transactions selected'} and return
    end

    chalan_amount = share_transactions.sum(:bank_deposit)
    deposited_date = Time.now
    deposited_date_bs = ad_to_bs(Time.now)
    @nepse_chalan = NepseChalan.new(deposited_date_bs: deposited_date_bs, deposited_date: deposited_date, chalan_amount: chalan_amount)
    @nepse_chalan.nepse_settlement_id = nepse_settlement_id
    nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")

    res = false
    ActiveRecord::Base.transaction do

      first_transaction_number = share_transactions.first.contract_no
      last_transaction_number = nil
      if share_transactions.size > 1
        last_transaction_number = share_transactions.last.contract_no
      end

      if last_transaction_number.nil?
        description = "Settlement by Bank Transfer for Transaction number #{first_transaction_number} Settlement ID (#{nepse_settlement_id})"
      else
        description = "Settlement by Bank Transfer for Transaction numbers #{first_transaction_number} - #{last_transaction_number} Settlement ID (#{nepse_settlement_id})"
      end


      voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
      voucher.desc = description
      voucher.complete!
      voucher.save!

      process_accounts(bank_ledger, voucher, false, chalan_amount, description, session[:user_selected_branch_id], Time.now.to_date)
      process_accounts(nepse_ledger, voucher, true, chalan_amount, description, session[:user_selected_branch_id], Time.now.to_date)

      @nepse_chalan.voucher = voucher
      @nepse_chalan.share_transactions = share_transactions
      res = true if @nepse_chalan.save
    end

    respond_to do |format|
      if res
        format.html { redirect_to @nepse_chalan, notice: 'Nepse chalan was successfully created.' }
        format.json { render :show, status: :created, location: @nepse_chalan }
      else
        format.html { render :new }
        format.json { render json: @nepse_chalan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nepse_chalans/1
  # PATCH/PUT /nepse_chalans/1.json
  def update
    respond_to do |format|
      if @nepse_chalan.update(nepse_chalan_params)
        format.html { redirect_to @nepse_chalan, notice: 'Nepse chalan was successfully updated.' }
        format.json { render :show, status: :ok, location: @nepse_chalan }
      else
        format.html { render :edit }
        format.json { render json: @nepse_chalan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nepse_chalans/1
  # DELETE /nepse_chalans/1.json
  def destroy
    @nepse_chalan.destroy
    respond_to do |format|
      format.html { redirect_to nepse_chalans_url, notice: 'Nepse chalan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_nepse_chalan
    @nepse_chalan = NepseChalan.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def nepse_chalan_params
    params.require(:nepse_chalan).permit(:deposited_date_bs, :deposited_date, :voucher_id)
  end
end
