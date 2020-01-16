class ChequeEntriesController < ApplicationController
  before_action :set_cheque_entry, only: [:show, :edit, :update, :destroy, :bounce_show, :bounce_do, :represent_show, :represent_do, :void_show, :void_do]
  before_action -> {authorize @cheque_entry}, only: [:show, :edit, :update, :destroy, :bounce_show, :bounce_do, :represent_show, :represent_do, :void_show, :void_do]
  before_action -> {authorize ChequeEntry}, except: [:show, :edit, :update, :destroy, :bounce_show, :bounce_do, :represent_show, :represent_do, :void_show, :void_do]

  # GET /cheque_entries
  # GET /cheque_entries.json
  def index
    # default landing action for '/cheque_entries'
    if params[:filterrific].blank?
      respond_to do |format|
        format.html { redirect_to cheque_entries_path('filterrific[by_cheque_entry_status]':'assigned') }
      end
      return
    end

    @filterrific = initialize_filterrific(
        ChequeEntry.by_branch_id(selected_branch_id),
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_beneficiary_name: ChequeEntry.by_branch_id(selected_branch_id).options_for_beneficiary_name(params[:filterrific]),
            by_bank_account_id: ChequeEntry.by_branch_id(selected_branch_id).options_for_bank_account_select(selected_branch_id),
            by_cheque_entry_status: ChequeEntry.by_branch_id(selected_branch_id).options_for_cheque_entry_status,
            by_cheque_issued_type: ChequeEntry.by_branch_id(selected_branch_id).options_for_cheque_issued_type
        },
        persistence_id: false
    ) or return
    items_per_page = params[:paginate] == 'false' ? ChequeEntry.by_branch_id(selected_branch_id).all.count : 20
    @cheque_entries = @filterrific.find.order(cheque_number: :asc).includes(:bank_account, :additional_bank).page(params[:page]).per(items_per_page).decorate

    respond_to do |format|
      format.html
      format.js
    end
      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :index }
      format.json { render json: flash.now[:error], status: :unprocessable_entity }
    end

      # Recover from invalid param sets, e.g., when a filter refers to the
      # database id of a record that doesn’t exist any more.
      # In this case we reset filterrific and discard all filter params.
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /cheque_entries/1
  # GET /cheque_entries/1.json
  def show
     cheque_activity = ChequeEntries::Activity.new(@cheque_entry, current_tenant.full_name, current_user.id, selected_branch_id, selected_fy_code)
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintChequeEntry.new(@cheque_entry, @name, @cheque_date, current_tenant)
        send_data pdf.render, filename: "ChequeEntry_#{@cheque_entry.id}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  def show_multiple
    @cheque_entry_ids = params[:cheque_entry_ids].present? ? params[:cheque_entry_ids].map(&:to_i) : []
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Print::PrintMultipleChequeEntries.new(@cheque_entry_ids, current_tenant)
        send_data pdf.render, filename: "MultipleChequeEntries#{@cheque_entry_ids.to_s}.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  # GET /cheque_entries/new
  def new
    # @cheque_entry = ChequeEntry.new
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @bank_accounts = BankAccount.by_branch_id(selected_branch_id).all.order(:bank_name)
  end

  # GET /cheque_entries/1/edit
  def edit
  end

  # TODO fix this hack
  def get_cheque_number
    @bank_account_ledger_id = params[:bank_account_id].to_i if params[:bank_account_id].present?

    if @bank_account_ledger_id.present?
      ledger = Ledger.find_by(id: @bank_account_ledger_id)
      cheque_entry = ChequeEntry.next_available_serial_cheque(ledger.bank_account_id)
    end


    cheque_number = cheque_entry.nil? ? 0 : cheque_entry.cheque_number

    respond_to do |format|
      format.html { render plain: cheque_number.to_s }
      format.json { render json: cheque_number, status: :ok }
    end
  end

  #   #
  #   # Make the cheque_entry Void.
  #   # - Change status of cheque_entry to void
  #   # - Reverse the voucher entry associated with the cheque_entry
  #   #   - reverse settlement
  #   # Notes:
  #   # - Receipt cheque and Payment cheque can both be void
  #   # - Receipt cheque can only be bounced and represented
  #   # - Void cheque can't be represented
  #   #
  #   def make_void
  #     @back_path = request.referer || @cheque_entry
  #     if @cheque_entry.printed? || @cheque_entry.bounced? || @cheque_entry.void?
  #       redirect_to @back_path, :flash => {:error => 'The cheque entry can not be made void. It is either printed, voided or bounced already.'} and return
  #     else
  #       reject(:void, @back_path, @back_path)
  #       redirect_to @back_path
  #     end
  #   end
  #
  #   # GET /cheque_entries/bounce
  #   def bounce
  #     @back_path = request.referer || cheque_entries_path
  #     if @cheque_entry.payment? || @cheque_entry.bounced?
  #       redirect_to @back_path, :flash => {:error => 'The Cheque cant be Bounced.'} and return
  #     else
  #       reject(:bounce, @back_path, @back_path)

  # get
  def void_show
    cheque_activity = ChequeEntries::Activity.new(@cheque_entry, current_tenant.full_name, current_user.id, selected_branch_id, selected_fy_code)
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
  end

  # patch
  def void_do
    void_date_bs = params.dig(:cheque_entry, :void_date)
    void_narration = params.dig(:cheque_entry, :void_narration)
    cheque_activity = ChequeEntries::VoidActivity.new(@cheque_entry, void_date_bs, void_narration, current_tenant.full_name, selected_branch_id, selected_fy_code, current_user.id)
    cheque_activity.process
    if cheque_activity.error_message.present?
      @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
      flash[:alert] = cheque_activity.error_message
      render :void_show  and return
    end
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
    redirect_to @cheque_entry, :flash => {:notice => 'Cheque voided succesfully'} and return
  end

  # get
  def bounce_show
    cheque_activity = ChequeEntries::Activity.new(@cheque_entry, current_tenant.full_name, current_user.id, selected_branch_id, selected_fy_code)
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
  end

  # patch
  def bounce_do
    bounce_date_bs = params.dig(:cheque_entry, :bounce_date)
    bounce_narration = params.dig(:cheque_entry, :bounce_narration)
    cheque_activity = ChequeEntries::BounceActivity.new(@cheque_entry, bounce_date_bs, bounce_narration, current_tenant.full_name, selected_branch_id, selected_fy_code, current_user.id)
    cheque_activity.process
    if cheque_activity.error_message.present?
      @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
      flash[:alert] = cheque_activity.error_message
      render :bounce_show  and return
    end
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
    redirect_to @cheque_entry, :flash => {:notice => 'Cheque bounced succesfully'} and return
  end

  def represent_show
    # TODO(sarojk): Representing disabled for now.  Revive later.
    redirect_to @cheque_entry, :flash => {:alert => 'Automatic representing of cheques is disabled. Please re-create a receipt voucher using the same cheque number to record representing of cheque.'} and return
    cheque_activity = ChequeEntries::Activity.new(@cheque_entry, current_tenant.full_name, current_user.id, selected_branch_id, selected_fy_code)
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
  end

  def represent_do
    represent_date_bs = params.dig(:cheque_entry, :represent_date)
    represent_narration = params.dig(:cheque_entry, :represent_narration)
    cheque_activity = ChequeEntries::RepresentActivity.new(@cheque_entry, represent_date_bs, represent_narration, current_tenant.full_name, current_user.id, selected_branch_id, selected_fy_code)
    cheque_activity.process
    if cheque_activity.error_message.present?
      @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
      flash[:alert] = cheque_activity.error_message
      render :represent_show  and return
    end
    @bank, @name, @cheque_date = cheque_activity.get_bank_name_and_date
    redirect_to @cheque_entry, :flash => {:notice => 'Cheque represented succesfully'} and return
  end

  # GET
  def update_print_status
    status = false
    message = ""
    cheque_entry_ids = params[:cheque_entry_ids]
    cheque_entry_ids.each do |cheque_entry_id|
      cheque = ChequeEntry.by_branch_id(selected_branch_id).find_by_id(cheque_entry_id)
      if cheque.to_be_printed?
        cheque.printed!
        status = true
      else
        message = "Cheque is already Printed" if cheque.printed?
      end
    end
    cheque_entries = ChequeEntry.by_branch_id(selected_branch_id).where(id: cheque_entry_ids.split(',')).pluck_to_hash(:id, :print_status)
    respond_to do |format|
      format.json { render json: {status: status, message: message, cheque_entries: cheque_entries}, status: :ok }
    end
  end

  def settlements_associated_with_cheque_entries
    cheque_entry_ids = params[:cheque_entry_ids]
    cheque_entries = ChequeEntry.by_branch_id(selected_branch_id).find(cheque_entry_ids.split(','))
    settlement_ids = []
    cheque_entries.each do |cheque_entry|
      if cheque_entry.payment?
        settlements = cheque_entry.dr_settlements
      else
        settlements = cheque_entry.cr_settlements
      end
      settlements.each do |settlement|
        settlement_ids << settlement.id
      end
    end
    respond_to do |format|
      format.json { render json: {status: status, settlement_ids: settlement_ids}, status: :ok }
    end
  end

  def bills_associated_with_cheque_entries
    cheque_entry_ids = params[:cheque_entry_ids]
    cheque_entries = ChequeEntry.by_branch_id(selected_branch_id).find(cheque_entry_ids.split(','))
    # FIX(sarojk): Doesn't look into second particulars, only first.
    bill_ids = []
    cheque_entries.each do |cheque_entry|
      bill_ids.concat cheque_entry.particulars.first.bills.where(client_account_id: cheque_entry.client_account_id).pluck(:id)
    end
    bill_ids.uniq!
    respond_to do |format|
      format.json { render json: {status: status, bill_ids: bill_ids}, status: :ok }
    end
  end

  def make_cheque_entries_unprinted
    status = true
    cheque_entry_ids = params[:cheque_entry_ids]
    cheque_entries = ChequeEntry.by_branch_id(selected_branch_id).find(cheque_entry_ids.split(','))
    cheque_entries.each do |cheque_entry|
      unless cheque_entry.to_be_printed!
        status = false
      end
    end
    cheque_entries = ChequeEntry.by_branch_id(selected_branch_id).where(id: cheque_entry_ids.split(',')).pluck_to_hash(:id, :print_status)
    respond_to do |format|
      format.json { render json: {status: status, cheque_entries: cheque_entries}, status: :ok }
    end
  end

  # POST /cheque_entries
  # POST /cheque_entries.json
  def create
    branch_id = selected_branch_id
    @bank_accounts = BankAccount.by_branch_id(selected_branch_id).all
    @bank_account_id = params[:bank_account_id].to_i if params[:bank_account_id].present?
    @start_cheque_number = params[:start_cheque_number].to_i if params[:start_cheque_number].present?
    @end_cheque_number = params[:end_cheque_number].present? ? params[:end_cheque_number].to_i : 0
    existing_cheque_numbers = ChequeEntry.by_branch_id(active_record_branch_id).where(bank_account_id: @bank_account_id).pluck(:cheque_number)
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
                      # when existing_cheque_numbers.any? {|n| (n.between?(@start_cheque_number, @end_cheque_number) && (n.bank_account_id == @bank_account_id) )}
                      #   "Cheque number cannot be duplicate for a bank"
                    else
                      has_error = false
                    end

    if !has_error
      ActiveRecord::Base.transaction do
        (@start_cheque_number..@end_cheque_number).each do |cheque_number|
          cheque_entry_params = with_branch_user_params({cheque_number: cheque_number, bank_account_id: @bank_account_id})
          cheque_entry = ChequeEntry.new(cheque_entry_params)

          if cheque_entry.valid?
            cheque_entry.save
          else
            has_error = true
            error_message = "Something went wrong!"
            raise ActiveRecord::Rollback
            break
          end
        end
      end
    end
    if has_error
      flash.now[:error] = error_message
    end


    respond_to do |format|
      if !has_error
        format.html { redirect_to cheque_entries_path('filterrific[by_bank_account_id]':@bank_account_id), notice: 'Cheque entry was successfully created.' }
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

  #
  # Entertains Ajax request made by combobox used in various views to populate clients.
  #
  def combobox_ajax_filter_for_beneficiary_name
    search_term = params[:q]
    beneficiary_names = []
    # 3 is the minimum search_term length to invoke find_similar_to_name
    if search_term && search_term.length >= 3
      beneficiary_names = ChequeEntry.by_branch_id(selected_branch_id).find_beneficiary_name_similar_to_term(search_term)
    end
    respond_to do |format|
      format.json { render json: beneficiary_names, status: :ok }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cheque_entry
    @cheque_entry = ChequeEntry.by_branch_id(selected_branch_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cheque_entry_params
   permitted_params = params.require(:cheque_entry).permit(:cheque_date, :beneficiary_name, :date_bs, :desc, :bounce_date, :bounce_narration, particulars_attributes: [:ledger_id, :description, :amount, :transaction_type])
   with_branch_user_params(permitted_params)

  end

end
