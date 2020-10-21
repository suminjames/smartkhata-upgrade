class VendorAccountsController < ApplicationController
  before_action :set_vendor_account, only: %i[show edit update destroy]

  before_action -> {authorize @vendor_account}, only: %i[show edit update destroy]
  before_action -> {authorize VendorAccount}, only: %i[index new create]

  # GET /vendor_accounts
  # GET /vendor_accounts.json
  def index
    @vendor_accounts = VendorAccount.all
  end

  # GET /vendor_accounts/1
  # GET /vendor_accounts/1.json
  def show
    @ledgers = @vendor_account.ledgers
    @ledgers = @ledgers.order(:name).page(params[:page]).per(20) if @ledgers.present?
  end

  # GET /vendor_accounts/new
  def new
    @vendor_account = VendorAccount.new
  end

  # GET /vendor_accounts/1/edit
  def edit
  end

  # POST /vendor_accounts
  # POST /vendor_accounts.json
  def create
    @vendor_account = VendorAccount.new(vendor_account_params)

    respond_to do |format|
      if @vendor_account.save
        format.html { redirect_to @vendor_account, notice: 'Vendor account was successfully created.' }
        format.json { render :show, status: :created, location: @vendor_account }
      else
        format.html { render :new }
        format.json { render json: @vendor_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendor_accounts/1
  # PATCH/PUT /vendor_accounts/1.json
  def update
    respond_to do |format|
      if @vendor_account.update(vendor_account_params)
        format.html { redirect_to @vendor_account, notice: 'Vendor account was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor_account }
      else
        format.html { render :edit }
        format.json { render json: @vendor_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendor_accounts/1
  # DELETE /vendor_accounts/1.json
  def destroy
    @vendor_account.destroy
    respond_to do |format|
      format.html { redirect_to vendor_accounts_url, notice: 'Vendor account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_vendor_account
    @vendor_account = VendorAccount.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def vendor_account_params
    permitted_params = params.require(:vendor_account).permit(:name, :address, :phone_number)
    with_branch_user_params(permitted_params)
  end
end
