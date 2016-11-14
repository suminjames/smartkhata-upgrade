class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy]

  before_action -> {authorize @share_transaction}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize ShareTransaction}, only: [:index, :new, :create, :deal_cancel, :pending_deal_cancel, :capital_gain_report, :threshold_transactions, :contract_note_details]

  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper
  include ShareInventoryModule

  layout 'application_custom', only: [:threshold_transactions]

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    # If logged in client tries to view information of clients which he doesn't have access to, redirect to home with
    # error flash message.
    if User.client_logged_in? &&
        !current_user.belongs_to_client_account(params.dig(:filterrific, :by_client_id).to_i)
      user_not_authorized and return
    end

    # this case is for the viewing of transaction by floorsheet date
    bs_date = params.dig(:filterrific, :by_date)
    if bs_date.present? && is_valid_bs_date?(bs_date)
      # this instance variable used in view to generate 'create transaction messages' button
      @transaction_date = bs_to_ad(bs_date)
    end

    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_isin_id: ShareTransaction.options_for_isin_select
        },
        persistence_id: false
    ) or return

    items_per_page = 20
    # In addtition to report generation, paginate is set to false by link used in #new view's view link.
    if params[:paginate] == 'false'
      if ['xlsx', 'pdf'].include?(params[:format])
        if params[:group_by_company] == "true"
          @share_transactions= @filterrific.find.includes(:isin_info, :bill, :client_account).order('isin_info_id ASC, date ASC, contract_no ASC')
        else
          @share_transactions= @filterrific.find.includes(:isin_info, :bill, :client_account).order('date ASC, contract_no ASC')
        end
      else
        @share_transactions= @filterrific.find.includes(:isin_info, :bill, :client_account).order('date ASC, contract_no ASC')
        # Needed for pagination to work
        @share_transactions = @share_transactions.page(0).per(@share_transactions.size)
      end
    else
      if params[:group_by_company] == "true"
        @share_transactions= @filterrific.find.includes(:isin_info, :bill, :client_account).order('isin_info_id ASC, date ASC, contract_no ASC').page(params[:page]).per(items_per_page)
        # This hash maps isin_info_ids(keys) with their respective counts(values)
        # Notice the ommision of pagination the query below. This is to have an overall cardinality of the current search scope.
        # Eg: {2=>5, 29=>6, 98=>1, 103=>2, 111=>4, 133=>8, 145=>5, 209=>1, 219=>1, 444=>4}
        @grouped_isins_cardinality_hash = @filterrific.find.order(:isin_info_id).group(:isin_info_id).count(:isin_info_id)
        # This hash maps isin_info_ids(keys) with their respective end positions(values) while the isins are serially queued.
        # This is crucial in finding when to insert the total quantity flow row of an isin, when share transactions are grouped by company
        # Eg: {2=>5, 29=>11, 98=>12, 103=>14, 111=>18, 133=>26, 145=>31, 209=>32, 219=>33, 444=>37}
        # @grouped_isins_serialized_position_hash = Hash.new(0)
        @grouped_isins_serialized_position_hash = Hash.new(0)
        sum = 0
        @grouped_isins_cardinality_hash.each do |isin, value|
          sum = sum + value
          @grouped_isins_serialized_position_hash[isin] = sum
        end
      else
        @share_transactions= @filterrific.find.includes(:isin_info, :bill, :client_account).order('date ASC, contract_no ASC').page(params[:page]).per(items_per_page)
      end
    end

    @download_path_xlsx = share_transactions_path({format:'xlsx', paginate: 'false'}.merge params)
    @download_path_pdf = share_transactions_path({format:'pdf', paginate: 'false'}.merge params)

    @print_path_pdf_in_regular = share_transactions_path({format:'pdf'}.merge params)
    @print_path_pdf_in_letter_head =share_transactions_path({format:'pdf', print_in_letter_head: 1}.merge params)

    if params[:filterrific] && params[:group_by_company].present?
      params[:filterrific][:group_by_company] = params[:group_by_company]
    end

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        print_in_letter_head = params[:print_in_letter_head].present?
        pdf = Reports::Pdf::ShareTransactionsReport.new(@share_transactions, params[:filterrific], current_tenant, print_in_letter_head)
        send_data pdf.render, filename:  Reports::Pdf::ShareTransactionsReport.file_name(params[:filterrific]) + '.pdf', type: 'application/pdf'
      end
      format.xlsx do
        report = Reports::Excelsheet::ShareTransactionsReport.new(@share_transactions, params[:filterrific], current_tenant)
        if report.generated_successfully?
          # send_file(report.path, type: report.type)
          send_data report.file, type: report.type, filename: report.filename
          report.clear
        else
          # This should be ideally an ajax notification!
          # preserve params??
          redirect_to share_transactions_path, flash: { error: report.error }
        end
      end
    end

      # Recover from 'invalid date' error in particular, among other RuntimeErrors.
      # OPTIMIZE(sarojk): Propagate particular error to specific field inputs in view.
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = e.message
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

  def threshold_transactions
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_isin_id: ShareTransaction.options_for_isin_select
        },
        persistence_id: false
    ) or return
    items_per_page = 20
    if params[:paginate] == 'false'
      @share_transactions= @filterrific.find.above_threshold.includes(:client_account).order('date ASC, contract_no ASC')
    else
      @share_transactions= @filterrific.find.above_threshold.includes(:client_account).order('date ASC, contract_no ASC').page(params[:page]).per(items_per_page)
    end

    @download_path_pdf = threshold_transactions_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)
    @download_path_pdf_for_letter_head = threshold_transactions_share_transactions_path({format:'pdf', paginate: 'false', print_in_letter_head: 1}.merge params)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        print_in_letter_head = params[:print_in_letter_head].present?
        pdf = Reports::Pdf::ThresholdShareTransactionsReport.new(@share_transactions, params[:filterrific], current_tenant, print_in_letter_head)
        send_data pdf.render, filename:  "Threshold_Transactions_Report.pdf", type: 'application/pdf'
      end
    end

  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = e.message
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

  def deal_cancel
    if params[:id].present?
      from_path = params[:from_path] || deal_cancel_share_transactions_path
      deal_cancel = DealCancelService.new(transaction_id: params[:id], broker_code: current_tenant.broker_code)
      deal_cancel.process
      @share_transaction = deal_cancel.share_transaction
      if deal_cancel.error_message.present?
        redirect_to from_path, alert: deal_cancel.error_message and return
      else
        @share_transaction = nil
        redirect_to from_path, notice: deal_cancel.info_message and return
      end
    end

    if params[:contract_no].present? && params[:transaction_type].present?
      case params[:transaction_type]
        when "selling"
          transaction_type = ShareTransaction.transaction_types[:selling]
        when "buying"
          transaction_type = ShareTransaction.transaction_types[:buying]
        else
          return
      end
      @is_searched = true
      @share_transaction = ShareTransaction.not_cancelled.find_by(contract_no: params[:contract_no], transaction_type: transaction_type)
    end
  end

  def capital_gain_report
    @filterrific = initialize_filterrific(
        ShareTransaction.selling,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        },
        persistence_id: false
    ) or return

    @share_transactions = @filterrific.find.includes(:isin_info, :bill, :client_account).decorate

    @download_path_xlsx = capital_gain_report_share_transactions_path({format:'xlsx'}.merge params)
    @download_path_pdf = capital_gain_report_share_transactions_path({format:'pdf'}.merge params)

    respond_to do |format|
      format.html
      format.js
      # format.xlsx do
      # end
      format.pdf do
        pdf = Reports::Pdf::CustomerCapitalGainReport.new(@share_transactions, current_tenant, {:print_in_letter_head => params[:print_in_letter_head]})
        send_data pdf.render, filename: "CapitalGainReport_#{@share_transactions.first.client_account.nepse_code}.pdf", type: 'application/pdf'
      end
    end

  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :capital_gain_report}
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

  def contract_note_details
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        persistence_id: false
    ) or return

    @share_transactions = @filterrific.find.includes(:isin_info, :bill, :client_account).decorate

    @download_path_xlsx = contract_note_details_share_transactions_path({format:'xlsx'}.merge params)
    @download_path_pdf =  contract_note_details_share_transactions_path({format:'pdf'}.merge params)

    if params.dig(:filterrific, :by_date).present?
      @share_transactions = @filterrific.find.includes(:isin_info, :client_account).order(contract_no: :desc)
      @share_transactions = @share_transactions.page(0).per(@share_transactions.size)
    else
      empty_array = []
      @share_transactions = Kaminari.paginate_array(empty_array).page(0).per(1000)
    end

    respond_to do |format|
      format.html
      format.js
      # format.xlsx do
      # end
      format.pdf do
        pdf = Reports::Pdf::ContractNoteDetails.new(@share_transactions, current_tenant, {:print_in_letter_head => params[:print_in_letter_head]})
        send_data pdf.render, filename: "ContractNoteDetailsReport.pdf", type: 'application/pdf'
      end
    end

  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = 'One of the search options provided is invalid.'
      format.html { render :contract_note_details}
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

  def pending_deal_cancel
    if params[:id].present?
      deal_cancel = DealCancelService.new(transaction_id: params[:id], approval_action: params[:approval_action], broker_code: current_tenant.broker_code)
      deal_cancel.process
      if deal_cancel.error_message.present?
        flash.now[:error] = deal_cancel.error_message
      else
        flash.now[:notice] = deal_cancel.info_message
      end
    end
    @share_transactions = ShareTransaction.deal_cancel_pending
  end

  # GET /share_transactions/1
  # GET /share_transactions/1.json
  def show
  end

  # GET /share_transactions/new
  def new
    @share_transaction = ShareTransaction.new
  end

  # GET /share_transactions/1/edit
  def edit
  end

  # POST /share_transactions
  # POST /share_transactions.json
  def create
    @share_transaction = ShareTransaction.new(share_transaction_params)

    respond_to do |format|
      if @share_transaction.save
        format.html { redirect_to @share_transaction, notice: 'Share transaction was successfully created.' }
        format.json { render :show, status: :created, location: @share_transaction }
      else
        format.html { render :new }
        format.json { render json: @share_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_transactions/1
  # PATCH/PUT /share_transactions/1.json
  def update
    # respond_to do |format|
    #   if @share_transaction.update(share_transaction_params)
    #     format.html { redirect_to @share_transaction, notice: 'Share transaction was successfully updated.' }
    #     format.json { render :index, status: :ok }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @share_transaction.errors, status: :unprocessable_entity }
    #   end
    # end
    @share_transaction.update_with_base_price(share_transaction_params)
  end

  # DELETE /share_transactions/1
  # DELETE /share_transactions/1.json
  def destroy
    @share_transaction.soft_delete
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_share_transaction
    @share_transaction = ShareTransaction.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def share_transaction_params
    params.require(:share_transaction).permit(:base_price)
  end
end
