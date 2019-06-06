class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @bank_account}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize BankAccount}, only: [:index, :new, :create, :generate_bills]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.by_branch_id(selected_branch_id).all
    # debugger
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.by_branch_id(selected_branch_id).new
    @bank_account.ledger = Ledger.new
    @bank_account.ledger.ledger_balances << LedgerBalance.new
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create

    @bank_account = BankAccount.new(bank_account_params)
    # @bank = Bank.find_by(id: @bank_account.bank_id)
    respond_to do |format|
      if @bank_account.save_custom
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully created.' }
        format.json { render :show, status: :created, location: @bank_account }
      else
        @bank_account.ledger.ledger_balances = @bank_account.ledger.ledger_balances[0..-2] if @valid
        format.html { render :new }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_accounts/1
  # PATCH/PUT /bank_accounts/1.json
  def update
    # debugger
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
    permitted_params = params.require(:bank_account).permit(:bank_id, :address, :bank_branch, :branch_id, :contact_no, :account_number, :default_for_receipt, :default_for_payment ,
                                         ledger_attributes: [ :group_id, ledger_balances_attributes: [:opening_balance, :opening_balance_type]])
    with_branch_user_params(permitted_params)
  end

  def bank_account_update_params
    permitted_update_params = params.require(:bank_account).permit(:default_for_receipt, :default_for_payment)
    with_branch_user_params(permitted_update_params)
  end
end
