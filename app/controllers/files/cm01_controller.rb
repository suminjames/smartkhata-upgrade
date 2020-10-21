class Files::Cm01Controller < Files::FilesController
  before_action -> {authorize self}

  @@file_name_contains = "CM01"

  def index
    @provisional_settlements = NepseProvisionalSettlement.order("settlement_id desc").page(params[:page]).per(20)
  end

  def new
    @skip_missing_allowed = params[:skip_missing_allowed]
    provisional_settlements = NepseProvisionalSettlement.order("settlement_id desc")
    @provisional_settlements = provisional_settlements.page(params[:page]).per(Files::PREVIEW_LIMIT)
    @list_incomplete = provisional_settlements.count > Files::PREVIEW_LIMIT
  end

  def import
    # authorize self
    @file = params[:file]
    skip_missing = params[:skip_missing] || false
    file_error("Please Upload a valid file") and return if is_invalid_file(@file, @@file_name_contains)

    cm01_upload = FilesImportServices::ImportCm01.new(@file, skip_missing)
    cm01_upload.process
    redirect_to new_files_cm01_path(skip_missing_allowed: true), flash: { error: cm01_upload.error_message } and return if cm01_upload.error_message

    redirect_to new_files_cm01_path
  end
end
