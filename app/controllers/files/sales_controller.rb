class Files::SalesController < Files::FilesController

  @@file_type = FileUpload::file_types[:orders]
  @@file_name_contains = "CM05"

  def index
    @settlements= SalesSettlement.order("settlement_id desc").page(params[:page]).per(20)
  end

  def new
    settlements = SalesSettlement.order("settlement_id desc")
    @settlements = settlements.page(params[:page]).per(Files::PREVIEW_LIMIT)
    @list_incomplete = settlements.count > Files::PREVIEW_LIMIT
  end

  def import
    # authorize self
    @file = params[:file]
    @settlement_date = params[:settlement_date]
    file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

    payout_upload = ImportPayout.new(@file, @settlement_date)
    payout_upload.process

    if payout_upload.error_message
      file_error(payout_upload.error_message)
      return
    end

    # sales settlement ids will be 1 if single settlement is uploaded
    @sales_settlement_id = payout_upload.sales_settlement_ids.first if payout_upload.sales_settlement_ids.size == 1

    # if single sales settlement redirect to the path where user can edit base price
    redirect_to sales_settlement_path(@sales_settlement_id) and return if @sales_settlement_id.present?

    # else redirect to pending sales settlement
    redirect_to sales_settlements_path(pending: true) if payout_upload.sales_settlement_ids.size > 1

  end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
