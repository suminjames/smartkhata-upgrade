class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: [:show, :edit, :update, :destroy]
  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.all
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.new
    @bank_account.ledger = Ledger.new
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create

    @bank_account = BankAccount.new(bank_account_params)

    @bank = Bank.find_by(id: @bank_account.bank_id)
    if @bank.present?
      @bank_account.ledger.name = "Bank:"+@bank.name+"(#{@bank_account.account_number})"
      @bank_account.bank_name = @bank.name
    end


    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully created.' }
        format.json { render :show, status: :created, location: @bank_account }
      else
        format.html { render :new }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_accounts/1
  # PATCH/PUT /bank_accounts/1.json
  def update
    respond_to do |format|
      if @bank_account.update(bank_account_update_params)
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_account }
      else
        format.html { render :edit }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account.destroy
    respond_to do |format|
      format.html { redirect_to bank_accounts_url, notice: 'Bank account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:bank_id, :account_number, :default_for_receipt, :default_for_payment,
                                           ledger_attributes: [:opening_blnc, :opening_blnc_type])
    end

    def bank_account_update_params
      params.require(:bank_account).permit(:default_for_receipt, :default_for_payment)
    end
end
