class Files::SysadminClientNepseMappingController < Files::FilesController
  def index
    authorize self
  end

  def new
    authorize self
  end

  def nepse_phone
    authorize self
  end

  def nepse_boid
    authorize self
  end

  def import
    authorize self
    @file = params[:file]
    @from_nepse = params[:from_nepse]
    @nepse_boid = params[:nepse_boid]
    @boid_nepse = params[:boid_nepse]

    # file_error("Please Upload a valid file") and return if (is_invalid_file(@file))

    file_upload = ImportSysadminFile.new(@file, @from_nepse, @nepse_boid, @boid_nepse)
    file_upload.process

    if file_upload.error_message
      file_error(file_upload.error_message)
      nil
    end

    # else redirect to settlement path
    # redirect_to nepse_settlement_path(payout_upload.nepse_settlement_id) and return
  end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
