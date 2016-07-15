class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: [:show, :edit, :update, :destroy]
  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.by_branch_id.all
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.by_branch_id.new
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
    # since this group is integral to the software in hand
    # any error raised here should be thoroughly examined
    @group_id = Group.find_by(name: "Current Assets").id
    @valid = false
    @success = false
    total_balance = 0.0

    @bank = Bank.find_by(id: @bank_account.bank_id)
    if @bank.present?
      @bank_account.ledger.name = "Bank:"+@bank.name+"(#{@bank_account.account_number})"
      @bank_account.ledger.group_id = @group_id
      @bank_account.bank_name = @bank.name
      @bank_account.ledger.ledger_balances.each do |balance|
        if balance.opening_balance >=0
          @valid = true
          total_balance += balance.opening_balance_type == "0" ? balance.opening_balance : ( balance.opening_balance * -1 )
          next
        end
        @valid = false
        flash.now[:error] = "Please dont include a negative amount"
        break
      end
    end

    if @valid
      @bank_account.ledger.ledger_balances << LedgerBalance.new(branch_id: nil, opening_balance: total_balance)
      @success = true if @bank_account.save
    end

    respond_to do |format|
      if @success
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
    params.require(:bank_account).permit(:bank_id, :address, :bank_branch, :branch_id, :contact_no, :account_number, :default_for_receipt, :default_for_payment ,
                                         ledger_attributes: [ :group_id, ledger_balances_attributes: [:opening_balance, :opening_balance_type]])
  end

  def bank_account_update_params
    params.require(:bank_account).permit(:default_for_receipt, :default_for_payment)
  end
end
