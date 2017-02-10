#TODO: Bill status should be (be default) in pending
class Files::FloorsheetsController < Files::FilesController
  before_action -> {authorize self}

  include CommissionModule
  include ShareInventoryModule
  include FiscalYearModule

  @@file_type = FileUpload::file_types[:floorsheet]
  @@file_name_contains = "FLOORSHEET"

  # amount above which it has to be settled within brokers.
  THRESHOLD_NEPSE_AMOUNT_LIMIT = 5000000

  def new
    floorsheets = FileUpload.where(file_type: @@file_type)
    @file_list = floorsheets.order("report_date desc").limit(Files::PREVIEW_LIMIT);
    @list_incomplete = floorsheets.count > Files::PREVIEW_LIMIT
    # if (@file_list.count > 1)
    # 	if((@file_list[0].report_date-@file_list[1].report_date).to_i > 1)
    # 		flash.now[:error] = "There is more than a day difference between last 2 reports.Please verify"
    # 	end
    # end
  end

  def index
    @file_list = FileUpload.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date DESC")
  end

  def import
    # TODO(subas): Catch invalid files where 1) all the 'data rows' are missing 2) File is 'blank'
    #              (Refer to floorsheet controller test for more info)
    #              (Sample files: test/fixtures/files/invalid_files)
    # get file from import
    @file = params[:file]
    @is_partial_upload = params[:is_partial_upload] == '1'
    if (is_invalid_file(@file, @@file_name_contains))
      file_error("Please Upload a valid file and make sure the file name contains floorsheet.") and return
    end

    floorsheet_upload = FilesImportServices::ImportFloorsheet.new(@file, @is_partial_upload)
    floorsheet_upload.process
    @processed_data = floorsheet_upload.processed_data
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
end

