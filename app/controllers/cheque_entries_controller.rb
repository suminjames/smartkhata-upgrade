class ChequeEntriesController < ApplicationController
  before_action :set_cheque_entry, only: [:show, :edit, :update, :destroy]

  # GET /cheque_entries
  # GET /cheque_entries.json
  def index
    @cheque_entries = ChequeEntry.where(particular_id: nil)
  end

  # GET /cheque_entries/1
  # GET /cheque_entries/1.json
  def show
  end

  # GET /cheque_entries/new
  def new
    # @cheque_entry = ChequeEntry.new
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @bank_accounts = BankAccount.all
  end

  # GET /cheque_entries/1/edit
  def edit
  end

# TODO fix this hack
  def get_cheque_number
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?

    if @bank_account_id.present?
      ledger = Ledger.find_by(id: @bank_account_id)
      cheque_entry = ChequeEntry.where(bank_account_id: ledger.bank_account_id).where(particular_id: nil).first
    end


    cheque_number = cheque_entry.nil?  ? 0 : cheque_entry.cheque_number

    respond_to do |format|
        format.html { render plain: cheque_number.to_s  }
        format.json { render json: cheque_number, status: :ok }
    end
  end

  # POST /cheque_entries
  # POST /cheque_entries.json
  def create
    @bank_accounts = BankAccount.all
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @start_cheque_number = params[:start_cheque_number].to_i if params[:start_cheque_number].present?
    @end_cheque_number =  params[:end_cheque_number].present? ? params[:end_cheque_number].to_i : 0

    error_message = ""
    has_error = false

    unless @bank_account_id.present?
      has_error = true
      error_message = "Bank Account cant be empty"
    end
    if @start_cheque_number.blank?
      has_error = true
      error_message = "Start Cheque Number cant be empty"
    elsif @start_cheque_number > @end_cheque_number
      has_error = true
      error_message = "Last cheque number should be greater than the first"
    elsif (@end_cheque_number - @start_cheque_number) > 501
      has_error = true
      error_message = "Only 500 cheque entries allowed"
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
      params.require(:cheque_entry).permit(:date_bs, :desc, particulars_attributes: [:ledger_id,:description, :amnt,:transaction_type])
    end
end
