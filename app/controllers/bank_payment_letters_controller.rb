class BankPaymentLettersController < ApplicationController
  before_action :set_bank_payment_letter, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @bank_payment_letter}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize BankPaymentLetter}, only: [:index, :new, :create, :finalize_payment]

  # GET /bank_payment_letters
  # GET /bank_payment_letters.json
  def index
    @bank_payment_letters = BankPaymentLetter.all
  end

  # GET /bank_payment_letters/1
  # GET /bank_payment_letters/1.json
  def show
    print_in_letter_head = false
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Pdf::PdfBankPaymentLetter.new(@bank_payment_letter, current_tenant, print_in_letter_head)
        send_data pdf.render, filename: "BankPaymentLetter#{@bank_payment_letter.id}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end

  end

  # GET /bank_payment_letters/new
  def new
    @settlement_id = params[:settlement_id]
    if params[:settlement_id].present?
      @bank_payment_letter = BankPaymentLetter.new
      @nepse_settlement = NepseSettlement.find_by(settlement_id: params[:settlement_id])
      @bills = []
      @bills = @nepse_settlement.bills_for_payment_letter_list(@selected_branch_id) if @nepse_settlement.present?
      @is_searched = true
      return
    end
    @bank_payment_letter = BankPaymentLetter.new
  end

  # GET /bank_payment_letters/1/edit
  def edit
  end

  # POST /bank_payment_letters
  # POST /bank_payment_letters.json
  def create
    @settlement_id = params[:settlement_id]
    @bank_payment_letter = BankPaymentLetter.new(bank_payment_letter_params.merge(branch_id: @selected_branch_id))
    @nepse_settlement = NepseSettlement.find(@bank_payment_letter.nepse_settlement_id)


    if selected_fy_code != get_fy_code(@nepse_settlement.settlement_date)
      redirect_to @bank_payment_letter, :flash => {:error => 'Please select the current fiscal year'} and return
    end

    particulars = false
    bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?
    payment_letter_generation = CreateBankPaymentLetterService.new(bill_ids: bill_ids, bank_payment_letter: @bank_payment_letter, current_user: current_user, branch_id: @selected_branch_id, fy_code: @selected_fy_code)
    particulars, settlement_amount, @bank_payment_letter  = payment_letter_generation.process

    if particulars
      @bank_payment_letter.particulars = particulars
      @bank_payment_letter.settlement_amount = settlement_amount
      if @bank_payment_letter.save
        result = true
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to @bank_payment_letter, notice: 'Bank payment letter was successfully created.' }
        format.json { render :show, status: :created, location: @bank_payment_letter }
      else
        flash.now[:error] = payment_letter_generation.error_message
        format.html { render :new }
        format.json { render json: @bank_payment_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  def finalize_payment
    success = false
    error_message = "There was some Error"
    @bank_payment_letter = BankPaymentLetter.find_by(id: params[:id].to_i)
    from_path = params[:from_path] || bank_payment_letters_path
    message = ""
    if @bank_payment_letter
      if !@bank_payment_letter.approved? && !@bank_payment_letter.cancelled?
        if params[:approve]
          BankPaymentLetter.transaction do
            @voucher = @bank_payment_letter.voucher
            @voucher.particulars.each do |particular|
              Ledgers::ParticularEntry.new(current_user.id).insert_particular(particular)
            end

            @voucher.reviewer_id = current_user.id
            @voucher.complete!
            @voucher.save!

            @bank_payment_letter.approved!

            @bank_payment_letter.bills.each do |bill|
              bill.approved!
            end

            success = true
            message = "Payment Letter  was successfully approved"
          end
        elsif params[:reject]
          # TODO(Subas) what happens to bill
          @bank_payment_letter.reviewer_id = current_user.id
          @voucher = @bank_payment_letter.voucher

          ActiveRecord::Base.transaction do

            @bills = @voucher.bills.sales.order(id: :desc)
            processed_bills = []

            @bills.each do |bill|
                bill.balance_to_pay = bill.net_amount
                bill.status = Bill.statuses[:pending]
                processed_bills << bill
            end

            processed_bills.each(&:save)

            @voucher.rejected!
            @voucher.save!
            @bank_payment_letter.cancelled!
            success = true if @bank_payment_letter.save!
          end

          message = 'Bank Letter was successfully rejected'
        end
      else
        error_message = 'Bank Letter is already processed.'
      end

    end

    respond_to do |format|
      format.html {
        redirect_to from_path, notice: message if success
        redirect_to from_path, alert: error_message unless success
      }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /bank_payment_letters/1
  # PATCH/PUT /bank_payment_letters/1.json
  def update
    respond_to do |format|
      if @bank_payment_letter.update(bank_payment_letter_params)
        format.html { redirect_to @bank_payment_letter, notice: 'Bank payment letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_payment_letter }
      else
        format.html { render :edit }
        format.json { render json: @bank_payment_letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_payment_letters/1
  # DELETE /bank_payment_letters/1.json
  def destroy
    @bank_payment_letter.destroy
    respond_to do |format|
      format.html { redirect_to bank_payment_letters_url, notice: 'Bank payment letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_payment_letter
      @bank_payment_letter = BankPaymentLetter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_payment_letter_params
      params.require(:bank_payment_letter).permit(:nepse_settlement_id, :bank_account_id)
    end
end
