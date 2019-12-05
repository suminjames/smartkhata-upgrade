class ShareTransactionsController < ApplicationController
  before_action :set_share_transaction, only: [:show, :edit, :update, :destroy, :process_closeout, :available_balancing_transactions]

  before_action -> {authorize @share_transaction}, only: [:show, :edit, :update, :destroy]
  before_action -> {authorize ShareTransaction}, only: [:index, :new, :create, :deal_cancel, :pending_deal_cancel, :capital_gain_report, :threshold_transactions, :contract_note_details, :securities_flow, :closeouts, :make_closeouts_processed, :process_closeout, :available_balancing_transactions, :sebo_report, :commission_report]

  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper
  include ShareInventoryModule

  layout 'application_custom', only: [:threshold_transactions]

  # GET /share_transactions
  # GET /share_transactions.json
  def index
    # If logged in client tries to view information of clients which he doesn't have access to, redirect to home with
    # error flash message.
    if current_user.client? &&
        !current_user.belongs_to_client_account(params.dig(:filterrific, :by_client_id).to_i)
      user_not_authorized and return
    end
    # this case is for the viewing of transaction by floorsheet date
    bs_date = params.dig(:filterrific, :by_date)
    @client_account = ClientAccount.find_by(id: params.dig(:filterrific, :by_client_id))

    if bs_date.present? && is_valid_bs_date?(bs_date)
      # this instance variable used in view to generate 'create transaction messages' button
      @transaction_date = bs_to_ad(bs_date)
    end
    @filterrific = initialize_filterrific(
        ShareTransaction.by_branch(selected_branch_id),
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
            by_isin_id: ShareTransaction.options_for_isin_select,
            by_transaction_type: ShareTransaction.options_for_transaction_type_select
        },
        persistence_id: false
    ) or return

    items_per_page = 20

    # In addtition to report generation, paginate is set to false by link used in #new view's view link.
    if params[:paginate] == 'false'
      if ['xlsx', 'pdf'].include?(params[:format])
        if params[:group_by_company] == "true"
          @share_transactions= @filterrific.find.includes(:isin_info, :bill).order('isin_info_id ASC, share_transactions.date ASC, contract_no ASC')
        else
          @share_transactions= @filterrific.find.includes(:isin_info, :bill).order('share_transactions.date ASC, contract_no ASC')
        end
      else
        @share_transactions= @filterrific.find.includes(:isin_info, :bill).order('share_transactions.date ASC, contract_no ASC')
        # Needed for pagination to work
        @share_transactions = @share_transactions.page(0).per(@share_transactions.size)
      end
    else
      if params[:group_by_company] == "true"
        @share_transactions= @filterrific.find.includes(:isin_info, :bill).order('isin_info_id ASC, share_transactions.date ASC, contract_no ASC').page(params[:page]).per(items_per_page)
        # This hash maps isin_info_ids(keys) with their respective counts(values)
        # Notice the ommision of pagination the query below. This is to have an overall cardinality of the current search scope.
        # Eg: {2=>5, 29=>6, 98=>1, 103=>2, 111=>4, 133=>8, 145=>5, 209=>1, 219=>1, 444=>4}
        @grouped_isins_cardinality_hash = @filterrific.find.order(:isin_info_id).group(:isin_info_id).count
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

        @share_transactions= @filterrific.find.includes(:isin_info, :bill).order('share_transactions.date ASC, contract_no ASC').page(params[:page]).per(items_per_page)
        @total_count = @filterrific.find.count if params.dig(:filterrific, :by_client_id)
      end
    end

    @download_path_xlsx = share_transactions_path(request.query_parameters.merge(format: 'xlsx', paginate: 'false'))
    @download_path_pdf = share_transactions_path(request.query_parameters.merge(format: 'pdf', paginate: 'false'))
    @print_path_pdf_in_regular = share_transactions_path(request.query_parameters.merge(format: 'pdf', paginate: 'false', print: 'true'))
    @print_path_pdf_in_letter_head = share_transactions_path(request.query_parameters.merge(format: 'pdf', paginate: 'false', print: 'true', print_in_letter_head: 1))

    if params[:filterrific] && params[:group_by_company].present?
      params[:filterrific][:group_by_company] = params[:group_by_company]
    end

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        print_in_letter_head = params[:print_in_letter_head].present?
        print = params[:print] == 'true'
        pdf = Reports::Pdf::ShareTransactionsReport.new(@share_transactions, params[:filterrific], current_tenant, print_in_letter_head)
        options = {
            filename: Reports::Pdf::ShareTransactionsReport.file_name(params[:filterrific]) + '.pdf',
            type: 'application/pdf'
        }
        # The value of disposition needs to be 'inline' for printing to work.
        # This is because during printing, the PDF is first loaded in a hidden iframe, then printed.
        options[:disposition] = "inline" if print
        send_data pdf.render, options
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


  def securities_flow
    # This @filterrific variable is not used for record fetching, but only for form state preservation in view.
    # The record fetching happens through class method 'ShareTransaction.securities_flows'
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        select_options: {
            by_isin_id: ShareTransaction.options_for_isin_select
        },
        persistence_id: false
    ) or return

    @is_securities_balance_view = params[:only_balance] == 'true'

    items_per_page = 20

    tenant_broker_id = current_tenant.broker_code
    @securities_flows = ShareTransaction.securities_flows(
        tenant_broker_id,
        params.dig(:filterrific, :by_isin_id),
        params.dig(:filterrific, :by_date),
        params.dig(:filterrific, :by_date_from),
        params.dig(:filterrific, :by_date_to),
        selected_branch_id
    )
    if params[:paginate] == 'false'
      items_per_page = @securities_flows.size
    end

    @securities_flows = Kaminari::paginate_array(@securities_flows).page(params[:page]).per(items_per_page)

    @download_path_xlsx = securities_flow_share_transactions_path({format:'xlsx', paginate: 'false'}.merge params)
    @download_path_pdf = securities_flow_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Reports::Pdf::SecuritiesFlowsReport.new(@securities_flows, @is_securities_balance_view, params, current_tenant)
        send_data pdf.render, filename:  pdf.file_name, type: 'application/pdf'
      end
      format.xlsx do
        report = Reports::Excelsheet::SecuritiesFlowsReport.new(@securities_flows, @is_securities_balance_view, params, current_tenant)
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
      format.html { render :securities_flow}
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

  def sebo_report
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        default_filter_params: { sorted_by: 'isin_info_asc' },
        select_options: {
            by_isin_id: ShareTransaction.options_for_isin_select
        },
        persistence_id: false
    ) or return

    @isin_infos = IsinInfo.where(company: nil).pluck(:isin)

    if @isin_infos.present?
      flash[:error] =  "Please Update company details for isin: #{@isin_infos.join(',')}"
    else
      @share_transactions = ShareTransaction.sebo_report(
          params.dig(:filterrific, :by_isin_id),
          params.dig(:filterrific, :by_date_from),
          params.dig(:filterrific, :by_date_to),
          selected_branch_id,
          selected_fy_code
      )
      fiscal_year = get_fiscal_year_from_fycode(selected_fy_code)
      @download_path_xlsx = sebo_report_share_transactions_path({format:'xlsx', paginate: 'false'}.merge params)
      @download_path_pdf = sebo_report_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)
    end

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Reports::Pdf::SeboReport.new(@share_transactions, params[:filterrific], current_tenant, fiscal_year)
        send_data pdf.render, filename:  pdf.file_name, type: 'application/pdf', disposition: "inline"
      end
      format.xlsx do
        report = Reports::Excelsheet::SeboReport.new(@share_transactions, params[:filterrific],current_tenant)
        if report.generated_successfully?
          # send_file(report.path, type: report.type)
          send_data report.file, type: report.type, filename: report.filename
          report.clear
        else
          # This should be ideally an ajax notification!
          # preserve params??
          redirect_to sebo_report_share_transactions_path, flash: { error: report.error }
        end
      end
    end
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = e.message
      format.html { render :sebo_report}
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

  def commission_report
    @filterrific = initialize_filterrific(
        ShareTransaction,
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific])
        },
        persistence_id: false
    ) or return

    @items_per_page = 50

    @commission_reports = ShareTransaction.commission_report(
        params.dig(:filterrific, :by_client_id),
        params.dig(:filterrific, :by_date_from),
        params.dig(:filterrific, :by_date_to),
        selected_fy_code
    )

    unless (params[:total_count])
      @total_count = ShareTransaction.total_count_for_commission_report(
          params.dig(:filterrific, :by_client_id),
          params.dig(:filterrific, :by_date_from),
          params.dig(:filterrific, :by_date_to),
          selected_fy_code
      )
    end

    # @commission_reports.instance_variable_set(:@total_count, 100)
    @commission_reports = Kaminari::paginate_array(@commission_reports).page(params[:page]).per(@items_per_page)

    @download_path_xlsx = commission_report_share_transactions_path({format:'xlsx', paginate: 'false'}.merge params)
    @download_path_pdf = commission_report_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Reports::Pdf::CommissionReport.new(@commission_reports, params[:filterrific], current_tenant)
        send_data pdf.render, filename:  pdf.file_name, type: 'application/pdf', disposition: "inline"
      end
      format.xlsx do
        report = Reports::Excelsheet::CommissionReport.new(@commission_reports, params[:filterrific],current_tenant)
        if report.generated_successfully?
          # send_file(report.path, type: report.type)
          send_data report.file, type: report.type, filename: report.filename
          report.clear
        else
          # This should be ideally an ajax notification!
          # preserve params??
          redirect_to commission_report_share_transactions_path, flash: { error: report.error }
        end
      end
    end
  rescue RuntimeError => e
    puts "Had to reset filterrific params: #{ e.message }"
    respond_to do |format|
      flash.now[:error] = e.message
      format.html { render :commission_report}
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
        },
        persistence_id: false
    ) or return

    if params[:filterrific]
      @share_transactions = ShareTransaction.threshold_report(
        params.dig(:filterrific, :by_date),
        params.dig(:filterrific, :by_client_id),
        params.dig(:filterrific, :by_date_from),
        params.dig(:filterrific, :by_date_to),
        selected_fy_code
      )
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
        ShareTransaction.for_cgt(selected_fy_code),
        params[:filterrific],
        select_options: {
            by_client_id: ClientAccount.options_for_client_select(params[:filterrific]),
        },
        persistence_id: false
    ) or return





    @total_capital_gain = arabic_number(@filterrific.find.pluck(:cgt).sum.to_f)
    @share_transactions = @filterrific.find.includes(:isin_info, :bill, :client_account)

    items_per_page = 20
    if params[:paginate] == 'false'
      items_per_page = @share_transactions.size
    end
    
    @share_transactions = @share_transactions.page(params[:page]).per(items_per_page).decorate
    @download_path_xlsx = capital_gain_report_share_transactions_path({format:'xlsx'}.merge params)
    @download_path_pdf = capital_gain_report_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)

    respond_to do |format|
      format.html
      format.js
      # format.xlsx do
      # end
      format.pdf do
        pdf = Reports::Pdf::CustomerCapitalGainReport.new(@share_transactions,params[:filterrific], current_tenant, {:print_in_letter_head => params[:print_in_letter_head]})
        send_data pdf.render, filename: "CapitalGainReport_#{@share_transactions.first.client_account.nepse_code}.pdf", type: 'application/pdf', :disposition => 'inline'
      end
      # format.xlsx do
      #   report = Reports::Excelsheet::CustomerCapitalGainReport.new(@share_transactions, params[:filterrific],current_tenant)
      #   if report.generated_successfully?
      #     # send_file(report.path, type: report.type)
      #     send_data report.file, type: report.type, filename: report.filename
      #     report.clear
      #   else
      #     # This should be ideally an ajax notification!
      #     # preserve params??
      #     redirect_to capital_gain_report_share_transactions_path, flash: { error: report.error }
      #   end
      # end
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

  def closeouts

    # this case is for the viewing of transaction by floorsheet date
    bs_date = params.dig(:filterrific, :by_date)
    if bs_date.present? && is_valid_bs_date?(bs_date)
      # this instance variable used in view to generate 'create transaction messages' button
      @transaction_date = bs_to_ad(bs_date)
    end

    @filterrific = initialize_filterrific(
        ShareTransaction.by_branch(selected_branch_id),
        params[:filterrific],
        select_options: {
            by_client_id_closeouts: ClientAccount.options_for_client_select_closeouts(params[:filterrific]),
            by_isin_id_closeouts: ShareTransaction.options_for_isin_select,
            by_transaction_type: ShareTransaction.options_for_transaction_type_select
        },
        persistence_id: false,
        default_filter_params: { sorted_by_closeouts: 'date_desc' },
    ) or return

    # @filterrific.select_options[:sorted_by] = 'close_out_asc'


    items_per_page = 20
    # In addtition to report generation, paginate is set to false by link used in #new view's view link.
    if params[:paginate] == 'false'
      if ['xlsx', 'pdf'].include?(params[:format])
        @share_transactions= @filterrific.find.includes(:isin_info, :client_account).order('share_transactions.date DESC, contract_no ASC')
      else
        @share_transactions= @filterrific.find.includes(:isin_info, :client_account).order('share_transactions.date DESC, contract_no ASC')
        # Needed for pagination to work
        @share_transactions = @share_transactions.page(0).per(@share_transactions.size)
      end
    else
      # @share_transactions= ShareTransaction.with_closeout.filterrific_find(@filterrific).includes(:isin_info, :client_account).order('date ASC, contract_no ASC').page(params[:page]).per(items_per_page).decorate
      @share_transactions= @filterrific.find.includes(:isin_info, :client_account).order('share_transactions.date DESC, contract_no ASC').page(params[:page]).per(items_per_page)


    end

    @download_path_xlsx = closeouts_share_transactions_path({format:'xlsx', paginate: 'false'}.merge params)
    @download_path_pdf = closeouts_share_transactions_path({format:'pdf', paginate: 'false'}.merge params)
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = Reports::Pdf::ShareTransactionsCloseoutReport.new(@share_transactions, params[:filterrific], current_tenant, false)
        send_data pdf.render, filename:  Reports::Pdf::ShareTransactionsCloseoutReport.file_name(params[:filterrific]) + '.pdf', type: 'application/pdf'
      end
      format.xlsx do
        report = Reports::Excelsheet::ShareTransactionsCloseoutReport .new(@share_transactions, params[:filterrific], current_tenant)
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


  def make_closeouts_processed
    status = true
    share_transaction_ids = params[:share_transaction_ids]
    closeout_settled = params[:make_processed] == 'true' ? true : false
    share_transactions = ShareTransaction.where(id: share_transaction_ids.split(','))
    share_transactions.update_all(closeout_settled: closeout_settled)

    share_transactions = ShareTransaction.where(id: share_transaction_ids.split(',')).pluck_to_hash(:id, :closeout_settled)
    respond_to do |format|
      format.json { render json: {status: status, share_transactions: share_transactions}, status: :ok }
    end
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

  # GET /share_transactions/1/available_balancing_transactions.json
  def available_balancing_transactions
    share_transactions = @share_transaction.available_balancing_transactions
    render json: {share_transactions: share_transactions}, status: :ok
  end

  # POST /share_transactions/1/process_closeout.json
  def process_closeout
    settlement_by = params[:settlement_by]
    closeout_settlement = ShortageSettlementService.new(@share_transaction, settlement_by, current_tenant, balancing_transaction_ids: params[:balancing_transaction_ids])
    closeout_settlement.process
    if closeout_settlement.error
      render json: {error: closeout_settlement.error}, status: :unprocessable_entity
    else
      render json: {message: 'Successfully processed'}, status: :ok
    end

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
    permitted_params = params.require(:share_transaction).permit(:base_price)
    with_branch_user_params(permitted_params)
  end
end
