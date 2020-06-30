class EdisReportsController < ApplicationController
  before_action :set_edis_report, only: [:show, :edit, :update, :destroy]

  before_action -> { authorize EdisReport }

  # GET /edis_reports
  # GET /edis_reports.json
  def index
    @edis_reports = EdisReport.blocked
  end

  # GET /edis_reports/1
  def show
    respond_to do |format|
      format.html
      format.json
      format.csv {
        report, file_name = @edis_report.csv_report(current_tenant)
        if report.present?
          send_data report, filename: file_name, type: 'text/csv; charset=utf-8'
        else
          error = "Upload response from CNS before proceeding"
          error = "No changes to download" if file_name.present?
          redirect_to @edis_report, flash: { error: error }
        end
      }
    end
  end

  # GET /edis_reports/new
  def new
    @edis_report = EdisReport.new(business_date: Time.current.to_date)
    @pending_reports = EdisReport.blocked.order(:business_date)
  end

  def import
    @edis_report_form = EdisReportForm.new
  end

  def process_import
    @edis_report_form = EdisReportForm.new(edis_report_form_params)
    if @edis_report_form.valid?
      @edis_report_form.import_file
      redirect_to import_edis_reports_path, notice: 'Successfully imported'
    else
      render 'import'
    end
  end

  # GET /edis_reports/1/edit
  def edit
  end

  # POST /edis_reports
  # POST /edis_reports.json
  def create
    @edis_report = EdisReport.new(edis_report_params)

    respond_to do |format|
      if @edis_report.save
        format.html { redirect_to edis_report_path(@edis_report, format: :csv) }
        format.json { render :show, status: :created, location: @edis_report }
      else
        format.html do
          redirect_to edis_report_path(@edis_report.previous_record, format: :csv) and return if @edis_report.previous_record.present?
          render :new
        end
        format.json { render json: @edis_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /edis_reports/1
  # PATCH/PUT /edis_reports/1.json
  def update
    respond_to do |format|
      if @edis_report.update(edis_report_params)
        format.html { redirect_to @edis_report, notice: 'Edis report was successfully updated.' }
        format.json { render :show, status: :ok, location: @edis_report }
      else
        format.html { render :edit }
        format.json { render json: @edis_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /edis_reports/1
  # DELETE /edis_reports/1.json
  def destroy
    @edis_report.destroy
    respond_to do |format|
      format.html { redirect_to edis_reports_url, notice: 'Edis report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_edis_report
      @edis_report = EdisReport.find(params[:id])
      authorize(@edis_report)
    end

  def edis_report_form_params
    params.require(:edis_report_form).permit( :file, :current_user_id)
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def edis_report_params
      with_branch_user_params(params.require(:edis_report).permit(:nepse_provisional_settlement_id, :business_date), false)
    end
end
