class Files::SysadminClientNepseMappingController < Files::FilesController

  def index
    authorize self
  end

  def new
    authorize self
  end

  def import
    authorize self
    @file = params[:file]

    # file_error("Please Upload a valid file") and return if (is_invalid_file(@file))

    file_upload = ImportSysadminFile.new(@file)
    file_upload.process

    if file_upload.error_message
      file_error(file_upload.error_message)
      return
    end

    # else redirect to settlement path
    # redirect_to sales_settlement_path(payout_upload.sales_settlement_id) and return
  end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
