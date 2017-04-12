class Files::SysadminTrialBalanceController < Files::FilesController
  before_action -> {authorize self}

  def index

  end

  def new

  end

  def import
    # authorize self
    @file = params[:file]

    # file_error("Please Upload a valid file") and return if (is_invalid_file(@file))

    file_upload = ImportSysadminTrialFile.new(@file)
    file_upload.process

    if file_upload.error_message
      file_error(file_upload.error_message)
      return
    end

    # else redirect to settlement path
    # redirect_to nepse_settlement_path(payout_upload.nepse_settlement_id) and return
  end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
