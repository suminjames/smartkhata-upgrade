class VouchersController < ApplicationController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy]
  before_action :set_voucher_general_params, only: [:new, :create]
  before_action :set_voucher_creation_params, only: [:create]

  before_action :authorize_voucher, only: [:convert_date, :index, :pending_vouchers, :new, :create, :finalize_payment, :set_bill_client]
  before_action :authorize_single_voucher, only: [:show, :edit, :update, :destroy]

  layout 'application_custom', only: [:new, :create]
  # GET /vouchers
  # GET /vouchers.json
  def index
    @vouchers = Voucher.pending.order("id ASC").decorate
  end

  def pending_vouchers
    # @vouchers = Voucher.pending.includes(:particulars).order("id ASC").references(:particulars).decorate
    @vouchers = Voucher.by_branch_fy_code(selected_branch_id, selected_fy_code).pending.includes(:particulars => :cheque_entries).order("cheque_entries.cheque_number DESC").references(:particulars, :cheque_entries).decorate
    render :index
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
    @from_path = request.referer || pending_vouchers_vouchers_path
    full_view = params[:full] || false
    @particulars = @voucher.particulars
    # this case is for payment by bank and should not affect others
    if @voucher.is_payment_bank && !full_view
      @from_path = vouchers_path if @from_path.match(/new/)

      # TODO remove this hack
      @particulars_with_bank = @particulars.has_bank
      # allow single payment by a cheque
      # no two payment can be made in a single voucher
      @particular_with_bank = @particulars.has_bank.cr.first
      @bank_account = @particular_with_bank.ledger.bank_account
      @cheque = @particular_with_bank.cheque_number

      # hack to show only the particulars with dr incase of more than one cheque entry in receipt
      if @particulars_with_bank.dr.size > 0
        @particulars = @particulars.has_bank.dr
      else
        @particulars = @particulars.general
      end

    end
    @particulars = @particulars.includes(:ledger, :voucher, :cheque_entries).order("cheque_entries.cheque_number ASC").references(:cheque_entries)
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintVoucher.new(@voucher, @particulars, @bank_account, @cheque, current_tenant)
        send_data pdf.render, filename: "Voucher_#{@voucher.voucher_number}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  # GET /vouchers/new
  # POST /vouchers/new
  def new
    # two way to post to this controller
    # either clear_ledger and client_account_id or client_account_id and bill_ids

    @voucher,
    @is_payment_receipt,
    @ledger_list_financial,
    @ledger_list_available,
    @default_ledger_id,
    @voucher_type,
    @vendor_account_list,
    @client_ledger_list = Vouchers::Setup.new(voucher_type: @voucher_type,
                                              client_account_id: @client_account_id,
                                              # bill_id: @bill_id,
                                              clear_ledger: @clear_ledger,
                                              bill_ids: @bill_ids).voucher_and_relevant(selected_branch_id, selected_fy_code)
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    available_branch_ids = Branch.permitted_branches_for_user(current_user).pluck(:id)
    # ignore some validations when the voucher type is sales or purchase
    @is_payment_receipt = false
    # create voucher with the posted parameters
    @voucher = Voucher.new(with_branch_user_params(voucher_params))
    voucher_creation = Vouchers::Create.new(voucher_type: @voucher_type,
                                            client_account_id: @client_account_id,
                                            bill_id: @bill_id,
                                            clear_ledger: @clear_ledger,
                                            voucher: @voucher,
                                            bill_ids: @bill_ids,
                                            voucher_settlement_type: @voucher_settlement_type,
                                            group_leader_ledger_id: @group_leader_ledger_id,
                                            vendor_account_id: @vendor_account_id,
                                            tenant_full_name: current_tenant.full_name,
                                            selected_fy_code: selected_fy_code,
                                            selected_branch_id: selected_branch_id,
                                            current_user: current_user)
    respond_to do |format|
      if voucher_creation.process

        @voucher = voucher_creation.voucher
        settlements = voucher_creation.settlements

        format.html {
          if settlements.size > 0 && !@voucher.is_payment_bank?
            # settlement_ids = settlements.pluck(:id)
            settlement_ids = settlements.map(&:id)
            # TODO (Remove this hack to show all the settlements)
            redirect_to show_multiple_settlements_path(settlement_ids: settlement_ids)
          else
            redirect_to @voucher, notice: 'Voucher was successfully created.'
          end
        }
        format.json { render :show, status: :created, location: @voucher }
      else
        @voucher = voucher_creation.voucher
        # ledger list and is purchase sales is required for the extra section to show up for payment and receipt case
        # ledger list financial contains only bank ledgers and cash ledger
        # ledger list no banks contains all ledgers except banks (to avoid bank transfers using voucher)
        @ledger_list_financial = voucher_creation.ledger_list_financial
        @ledger_list_available = voucher_creation.ledger_list_available
        @vendor_account_list = voucher_creation.vendor_account_list
        @client_ledger_list = voucher_creation.client_ledger_list
        @is_payment_receipt = voucher_creation.is_payment_receipt?(@voucher_type)
        @voucher_settlement_type = voucher_creation.voucher_settlement_type
        @group_leader_ledger_id = voucher_creation.group_leader_ledger_id
        @vendor_account_id = voucher_creation.vendor_account_id

        if voucher_creation.error_message
          flash.now[:error] = voucher_creation.error_message
        end
        format.html { render :new }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
      redirect_to :back
  end

  # PATCH/PUT /vouchers/1
  # PATCH/PUT /vouchers/1.json
  def update
    respond_to do |format|
      if @voucher.update(voucher_params)
        format.html { redirect_to @voucher, notice: 'Voucher was successfully updated.' }
        format.json { render :show, status: :ok, location: @voucher }
      else
        format.html { render :edit }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vouchers/1
  # DELETE /vouchers/1.json
  def destroy
    @voucher.destroy
    respond_to do |format|
      format.html { redirect_to vouchers_url, notice: 'Voucher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # TODO make sure authorization is performed
  # TODO (Subas) move this to Ledgers/particular entry
  def finalize_payment
    success = false
    error_message = "There was some Error"
    @voucher = Voucher.find_by(id: params[:id].to_i)
    from_path = params[:from_path]
    message = ""
    if @voucher
      if !@voucher.rejected? && !@voucher.complete?
        if params[:approve]
          Voucher.transaction do

            particular_ids = []
            @voucher.particulars.each do |particular|
              Ledgers::ParticularEntry.new(current_user.id).insert_particular(particular)
              particular_ids  << particular.id
            end

            cheque_ids = ChequeEntryParticularAssociation.where(particular_id: particular_ids).pluck(:cheque_entry_id).uniq
            ChequeEntry.unscoped.where(id: cheque_ids).each do |cheque_entry|
              cheque_entry.approved!
            end

            @voucher.reviewer_id = current_user&.id
            @voucher.complete!
            @voucher.save!
            success = true
            message = "Payment Voucher was successfully approved"
          end
        elsif params[:reject]
          # TODO(Subas) what happens to bill
          @voucher.current_user_id = current_user&.id
          voucher_amount = 0.0

          ActiveRecord::Base.transaction do
            # If cheque_entry not printed, it can/should be resuable.
            # Therefore, delete the cheque_entry and create a new cheque_entry with same cheque_number such that it is unassigned.
            particular_ids = @voucher.particulars.pluck(:id)

            cheque_ids = ChequeEntryParticularAssociation.where(particular_id: particular_ids).pluck(:cheque_entry_id).uniq
            ChequeEntry.unscoped.where(id: cheque_ids).each do |cheque_entry|
              if cheque_entry.printed?
                cheque_entry.current_user_id = current_user.id
                cheque_entry.void!
              else
                replacement_cheque_entry = ChequeEntry.new()
                replacement_cheque_entry.cheque_number = cheque_entry.cheque_number
                replacement_cheque_entry.bank_account_id= cheque_entry.bank_account_id
                replacement_cheque_entry.branch_id = cheque_entry.branch_id
                replacement_cheque_entry.fy_code= cheque_entry.fy_code
                replacement_cheque_entry.current_user_id = current_user.id
                # The destroy will also delete cheque_entry_particular_associations via model callbacks
                cheque_entry.destroy!
                replacement_cheque_entry.save!
              end
              voucher_amount += cheque_entry.amount
            end

            @bills = @voucher.bills.sales.order(id: :desc)
            processed_bills = []

            @bills.each do |bill|
              bill.current_user_id = current_user.id
              if voucher_amount + margin_of_error_amount < bill.net_amount
                bill.balance_to_pay = voucher_amount
                bill.status = Bill.statuses[:partial]
                processed_bills << bill
                break
              else
                bill.balance_to_pay = bill.net_amount
                bill.status = Bill.statuses[:pending]
                voucher_amount -= bill.net_amount
                processed_bills << bill
              end
            end

            processed_bills.each(&:save)

            # @voucher.cheque_entries.uniq.each do |cheque_entry|
            #   cheque_entry.void!
            # end

            @voucher.rejected!
            success = true if @voucher.save!

          end

          message = 'Payment Voucher was successfully rejected'
        end
      else
        error_message = 'Voucher is already processed.'
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


  # returns client account, bill, group of bills and amount to be paid
  def set_bill_client(client_account_id, bill_id, voucher_type)
    # set default values to nil
    client_account = nil
    bill = nil
    bills = []
    amount = 0.0
    # find the bills for the client
    if client_account_id.present?
      client_account = ClientAccount.find(client_account_id)
    elsif bill_id.present?
      bill = Bill.find(bill_id)
      client_account = bill.client_account
    else
      client_account = nil
      bill = nil
    end


    case voucher_type
      when Voucher.voucher_types[:receipt]
        # check if the client account is present
        # and grab all the bills from which we can receive amount if bill is not present
        # else grab the amount to be paid from the bill
        if client_account.present?
          unless bill.present?
            bills = client_account.bills.requiring_receive
            amount = bills.sum(:balance_to_pay)
          else
            bills = [bill]
            amount = bill.balance_to_pay
          end

          amount = amount.abs
        end

      when Voucher.voucher_types[:payment]
        if client_account.present?
          unless bill.present?
            bills = client_account.bills.requiring_payment
            amount = bills.sum(:balance_to_pay)
          else
            bills = [bill]
            amount = bill.balance_to_pay
          end
          amount = amount.abs
        end
    end
    amount = amount.round(2)
    return client_account, bill, bills, amount
  end


  def convert_date
    begin
      if params[:convert_to] == 'bs'
        date = ad_to_bs(params[:date])
      elsif params[:convert_to] == 'ad'
        date = bs_to_ad(params[:date])
      end
      render json: { date: date || '' }, status: :ok
    rescue
      render json: { error: 'Invalid Date'}, status: :forbidden
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_voucher
    @voucher = Voucher.find(params[:id]).decorate
  end

  def authorize_voucher
    authorize Voucher
  end

  def authorize_single_voucher
    authorize @voucher
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def voucher_params
    permitted_params = params.require(:voucher).permit(:date_bs, :voucher_type, :desc, particulars_attributes: [:ledger_id, :description, :amount, :transaction_type, :cheque_number, :additional_bank_id, :branch_id, :bills_selection, :selected_bill_names, :ledger_balance_adjustment, :current_user_id])
    with_branch_user_params(permitted_params)
  end

  def set_voucher_general_params
    # get parameters for voucher types and assign it as journal if not available
    @bill_ids = []
    @voucher_type = params[:voucher_type].to_i if params[:voucher_type].present? || Voucher.voucher_types[:journal]
    # client account id ensures the vouchers are on the behalf of the client
    @client_account_id = params[:client_account_id].to_i if params[:client_account_id].present?
    # get bill id if present
    @bill_id = params[:bill_id].to_i if params[:bill_id].present?
    @bill_ids = params[:bill_ids].map(&:to_i) if params[:bill_ids].present?
    # check if clear ledger balance is present
    @clear_ledger = set_clear_ledger
  end

  def set_voucher_creation_params
    @fixed_ledger_id = params[:fixed_ledger_id].to_i if params[:fixed_ledger_id].present?
    @cheque_number = params[:cheque_number].to_i if params[:cheque_number].present?
    @voucher_settlement_type = params[:voucher_settlement_type] if params[:voucher_settlement_type].present?
    @group_leader_ledger_id = params[:group_leader_ledger_id].to_i if params[:group_leader_ledger_id].present?
    @vendor_account_id = params[:vendor_account_id].to_i if params[:vendor_account_id].present?
  end

  # special case for which the ledger balance can be cleared all at once
  def set_clear_ledger
    clear_ledger = false
    if params[:clear_ledger].present?
      return true if (params[:clear_ledger] == true || params[:clear_ledger] == 'true')
    end
    clear_ledger
  end

end
