class Files::Cm01Controller < Files::FilesController
  before_action -> {authorize self}

  @@file_name_contains = "CM01"

  def index
    @provisional_settlements = NepseProvisionalSettlement.order("settlement_id desc").page(params[:page]).per(20)
  end

  def new
    provisional_settlements = NepseProvisionalSettlement.order("settlement_id desc")
    @provisional_settlements = provisional_settlements.page(params[:page]).per(Files::PREVIEW_LIMIT)
    @list_incomplete = provisional_settlements.count > Files::PREVIEW_LIMIT
  end

  def import
    # authorize self
    @file = params[:file]
    file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

    cm01_upload = FilesImportServices::ImportCm01.new(@file)
    cm01_upload.process

    if cm01_upload.error_message
      file_error(cm01_upload.error_message)
    end

    redirect_to new_files_cm01_path
  end
end

