#TODO: Bill status should be (be default) in pending
class Files::FloorsheetsController < Files::FilesController
  before_action -> {authorize self}

  include CommissionModule
  include ShareInventoryModule
  include FiscalYearModule

  @@file_type = FileUpload::file_types[:floorsheet]
  @@file_name_contains = "floor_sheet"

  # amount above which it has to be settled within brokers.
  THRESHOLD_NEPSE_AMOUNT_LIMIT = 5000000

  def new
    floorsheets = FileUpload.processed.where(file_type: @@file_type)
    @file_list = floorsheets.order("report_date desc").limit(Files::PREVIEW_LIMIT);
    @list_incomplete = floorsheets.count > Files::PREVIEW_LIMIT
  end

  def index
    @file_list = FileUpload.processed.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date DESC")
  end

  def import
    # TODO(subas): Catch invalid files where 1) all the 'data rows' are missing 2) File is 'blank'
    #              (Refer to floorsheet controller test for more info)
    #              (Sample files: test/fixtures/files/invalid_files)
    # get file from import
    @file = params[:file]
    # begin
    #   @value_date = bs_to_ad(params[:value_date_bs])
    #   unless parsable_date?(@value_date) && date_valid_for_fy_code(@value_date, selected_fy_code)
    #     file_error("Value date should lie within the current fiscal year!") and return
    #   end
    # rescue
    #   file_error("Value date should lie within the current fiscal year!") and return
    # end


    @is_partial_upload = params[:is_partial_upload] == '1'
    if (is_invalid_file(@file, @@file_name_contains))
      file_error("Please Upload a valid file and make sure the file name contains floor_sheet.") and return
    end

    floorsheet_upload = FilesImportServices::ImportFloorsheet.new(@file, current_user, selected_fy_code, @is_partial_upload)
    floorsheet_upload.process
    @date = floorsheet_upload.date
    if floorsheet_upload.error_message
      if floorsheet_upload.error_type == 'new_client_accounts_present'
        # As the messages in new client accounts can be pretty long, flash (which is stored in session with max size limit of 4Kb) might not be able to handle it in redirect to 'new' with flash message.
        # Instead, render import template itself accommodating error message.
        @error = true
        @new_client_accounts = floorsheet_upload.new_client_accounts
        @error_type = floorsheet_upload.error_type
        flash.now[:error] = floorsheet_upload.error_message
      else
        respond_to do |format|
          flash[:error] = floorsheet_upload.error_message
          format.html {redirect_to action: 'new' and return}
        end
      end
    end
  end

  def edit
    @file_upload = FileUpload.find(params[:id])
  end

  def change
    @file_upload = FileUpload.find(params[:id])
    begin
      @value_date = bs_to_ad(params[:value_date_bs])
      unless parsable_date?(@value_date) && date_valid_for_fy_code(@value_date, selected_fy_code, @file_upload.report_date)
        file_error("Value date should lie within the current fiscal year!") and return
      end
    rescue
      file_error("Value date should lie within the current fiscal year!") and return
    end

    unless @file_upload.update({ value_date: @value_date})
      file_error("Value date change was not successful") and return
    end
  end
end

