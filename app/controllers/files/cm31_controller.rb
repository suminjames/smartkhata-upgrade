class Files::Cm31Controller < Files::FilesController
  before_action -> {authorize self}

  @@file_name_contains = "CM31"

  def index
    @settlements= NepsePurchaseSettlement.order("settlement_id desc").page(params[:page]).per(20)
  end

  def new
    settlements = NepsePurchaseSettlement.order("settlement_id desc")
    @settlements = settlements.page(params[:page]).per(Files::PREVIEW_LIMIT)
    @list_incomplete = settlements.count > Files::PREVIEW_LIMIT
  end

  def import
    # authorize self
    @file = params[:file]
    @settlement_date = params[:settlement_date]
    file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

    cm31_upload = FilesImportServices::ImportCm31.new(@file, current_tenant, selected_fy_code, @settlement_date )
    cm31_upload.process

    if cm31_upload.error_message
      file_error(cm31_upload.error_message)
      return
    end

    # sales settlement ids will be 1 if single settlement is uploaded
    @nepse_settlement_id = cm31_upload.nepse_settlement_ids.first if cm31_upload.nepse_settlement_ids.size == 1

    # if single sales settlement redirect to the path where user can edit base price
    redirect_to nepse_purchase_settlement_path(@nepse_settlement_id) and return if @nepse_settlement_id.present?

    # else redirect to pending sales settlement
    redirect_to nepse_purchase_settlements_path if cm31_upload.nepse_settlement_ids.size > 1

  end
end
