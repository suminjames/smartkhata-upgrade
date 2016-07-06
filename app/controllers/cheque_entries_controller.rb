class ChequeEntriesController < ApplicationController
  before_action :set_cheque_entry, only: [:show, :edit, :update, :destroy, :bounce, :represent]
  # GET /cheque_entries
  # GET /cheque_entries.json
  def index
    if params[:type] == 'client'
      @cheque_entries = ChequeEntry.where.not(additional_bank_id: nil)
    elsif params[:type] == 'company'
      @cheque_entries = ChequeEntry.where(additional_bank_id: nil).where.not(status: 'unassigned')
    else
      @cheque_entries = ChequeEntry.unassigned
    end
  end

  # GET /cheque_entries/1
  # GET /cheque_entries/1.json
  def show
    if @cheque_entry.additional_bank_id.present?
      @bank = Bank.find_by(id: @cheque_entry.additional_bank_id)
      @name = current_tenant.full_name
    else
      @bank = @cheque_entry.bank_account.bank
      @name = @cheque_entry.beneficiary_name.present? ? @cheque_entry.beneficiary_name : "Internal Ledger"
    end
    @cheque_date = @cheque_entry.cheque_date.nil? ? DateTime.now : @cheque_entry.cheque_date

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintChequeEntry.new(@cheque_entry, @name, @cheque_date, current_tenant)
        send_data pdf.render, filename: "ChequeEntry_#{@cheque_entry.id}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  # GET /cheque_entries/new
  def new
    # @cheque_entry = ChequeEntry.new
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @bank_accounts = BankAccount.all.order(:bank_name)
  end

  # GET /cheque_entries/1/edit
  def edit
  end

  # TODO fix this hack
  def get_cheque_number
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?

    if @bank_account_id.present?
      ledger = Ledger.find_by(id: @bank_account_id)
      cheque_entry = ChequeEntry.unassigned.where(bank_account_id: ledger.bank_account_id).first
    end


    cheque_number = cheque_entry.nil? ? 0 : cheque_entry.cheque_number

    respond_to do |format|
      format.html { render plain: cheque_number.to_s }
      format.json { render json: cheque_number, status: :ok }
    end
  end

  # GET /cheque_entries/bounce
  def bounce
    @back_path = request.referer || cheque_entries_path
    if @cheque_entry.additional_bank_id!= nil && @cheque_entry.bounced?
      redirect_to @back_path, flash: {:error => 'The Cheque cant be Bounced.'} and return
    end


    voucher = @cheque_entry.vouchers.uniq.first
    @bills = voucher.bills.purchase.order(id: :desc)
    cheque_amount = @cheque_entry.amount
    processed_bills = []

    @bills.each do |bill|
      if cheque_amount + margin_of_error_amount < bill.net_amount
        bill.balance_to_pay = cheque_amount
        bill.status = Bill.statuses[:partial]
        processed_bills << bill
        break
      else
        bill.balance_to_pay = bill.net_amount
        bill.status = Bill.statuses[:pending]
        cheque_amount -= bill.net_amount
        processed_bills << bill
      end
    end

    ActiveRecord::Base.transaction do
      processed_bills.each(&:save)

      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
      new_voucher.bills_on_settlement = processed_bills

      description = "Cheque number #{@cheque_entry.cheque_number} bounced"
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description)
      end

      @cheque_entry.bounced!
    end

    if @cheque_entry.additional_bank_id.present?
      @bank = Bank.find_by(id: @cheque_entry.additional_bank_id)
      @name = current_tenant.full_name
    else
      @bank = @cheque_entry.bank_account.bank
      @name = @cheque_entry.beneficiary_name.present? ? @cheque_entry.beneficiary_name : "Internal Ledger"
    end
    @cheque_date = @cheque_entry.cheque_date.nil? ? DateTime.now : @cheque_entry.cheque_date
    flash.now[:notice] = 'Cheque bounce recorded succesfully.'
    render :show
  end

  # GET /cheque_entries/represent
  def represent
    @back_path = request.referer || cheque_entries_path
    if @cheque_entry.additional_bank_id!= nil && !@cheque_entry.bounced?
      redirect_to @back_path, flash: {:error => 'The Cheque cant be represented.'} and return
    end

    voucher = @cheque_entry.vouchers.uniq.last

    ActiveRecord::Base.transaction do
      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
      description = "Cheque number #{@cheque_entry.cheque_number} represented"
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description)
      end

      @cheque_entry.represented!
    end

    if @cheque_entry.additional_bank_id.present?
      @bank = Bank.find_by(id: @cheque_entry.additional_bank_id)
      @name = current_tenant.full_name
    else
      @bank = @cheque_entry.bank_account.bank
      @name = @cheque_entry.beneficiary_name.present? ? @cheque_entry.beneficiary_name : "Internal Ledger"
    end
    @cheque_date = @cheque_entry.cheque_date.nil? ? DateTime.now : @cheque_entry.cheque_date
    flash.now[:notice] = 'Cheque Represent recorded succesfully.'
    render :show
  end

  # GET
  def update_print
    status = false
    message = ""

    cheque = ChequeEntry.find_by(id: params[:cheque_id].to_i) if params[:cheque_id].present?
    if cheque.to_be_printed?
      cheque.printed!
      status = true
    else
      message = "Cheque is already Printed" if cheque.printed?
    end

    respond_to do |format|
      format.json { render json: {status: status, message: message}, status: :ok }
    end
  end

  # POST /cheque_entries
  # POST /cheque_entries.json
  def create
    @bank_accounts = BankAccount.all
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @start_cheque_number = params[:start_cheque_number].to_i if params[:start_cheque_number].present?
    @end_cheque_number = params[:end_cheque_number].present? ? params[:end_cheque_number].to_i : 0
    existing_cheque_numbers = ChequeEntry.where(bank_account_id: @bank_account_id).pluck(:cheque_number)
    has_error = true

    error_message = case
    when @bank_account_id.blank?
      "Bank Account cannot be empty"
    when @start_cheque_number.blank?
      "Start Cheque Number cannot be empty"
    when @start_cheque_number <= 0 || @end_cheque_number <= 0
      "Cheque numbers cannot be negative"
    when @start_cheque_number > @end_cheque_number
      "Last cheque number should be greater than the first"
    when (@end_cheque_number - @start_cheque_number) > 501
      "Maximum of 500 cheque entries allowed"
    when existing_cheque_numbers.any? {|n| n.between? @start_cheque_number, @end_cheque_number }
      "Cheque number cannot be duplicate for a bank"
    else
      has_error = false
    end

    if !has_error
      ActiveRecord::Base.transaction do
        (@start_cheque_number..@end_cheque_number).each do |cheque_number|
          ChequeEntry.create!(cheque_number: cheque_number, bank_account_id: @bank_account_id)
        end
      end
    else
      flash.now[:error] = error_message
    end


    respond_to do |format|
      if !has_error
        format.html { redirect_to cheque_entries_path, notice: 'Cheque entry was successfully created.' }
        format.json { render :show, status: :created, location: @cheque_entry }
      else
        format.html { render :new }
        format.json { render json: @cheque_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheque_entries/1
  # PATCH/PUT /cheque_entries/1.json
  def update
    respond_to do |format|
      if @cheque_entry.update(cheque_entry_params)
        format.html { redirect_to @cheque_entry, notice: 'Cheque entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @cheque_entry }
      else
        format.html { render :edit }
        format.json { render json: @cheque_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheque_entries/1
  # DELETE /cheque_entries/1.json
  def destroy
    @cheque_entry.destroy
    respond_to do |format|
      format.html { redirect_to cheque_entries_url, notice: 'Cheque entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cheque_entry
    @cheque_entry = ChequeEntry.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cheque_entry_params
    params.require(:cheque_entry).permit(:date_bs, :desc, particulars_attributes: [:ledger_id, :description, :amount, :transaction_type])
  end
end
