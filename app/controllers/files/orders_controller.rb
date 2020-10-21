class Files::OrdersController < Files::FilesController
  before_action -> {authorize self}
  helper_method :is_active_sub_menu_option

  @@file_type = FileUpload.file_types[:orders]
  @@file_name_contains = "order"

  def index
    @file_list = FileUpload.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date desc")
  end

  def new
    orders = FileUpload.where(file_type: @@file_type)
    @file_list = orders.order("report_date desc").limit(Files::PREVIEW_LIMIT)
    @list_incomplete = orders.count > Files::PREVIEW_LIMIT
  end

  def import
    # TODO(subas): authorize self
    @file = params[:file]
    @order_upload = ImportOrder.new(@file)

    # Redirect to request origination page /new rather than redirecting to import
    if is_invalid_file(@file, @@file_name_contains)
      @order_upload.error = true
      @order_upload.error_message = 'Please upload a valid file.'
    else
      @processed_data = @order_upload.process
    end

    if @order_upload.error_message
      if @order_upload.error_type == 'new_client_accounts_present'
        flash.now[:error] = @order_upload.error_message
      else
        respond_to do |format|
          flash[:error] = @order_upload.error_message
          format.html { redirect_to action: 'new' and return }
        end
      end
    end
  end
end
