class Files::OrdersController < Files::FilesController
  helper_method :is_active_sub_menu_option

  @@file_type = FileUpload::file_types[:orders]
  @@file_name_contains = "order"

  def index
    @file_list = FileUpload.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date desc")
  end

	def new
    @file_list = FileUpload.where(file_type: @@file_type).order("report_date desc").limit(10)
    flash.discard
	end

	def import
		# TODO(subas): authorize self
		@file = params[:file]

    # Redirect to request origination page /new rather than redirecting to import
    if is_invalid_file(@file, @@file_name_contains)
      respond_to do |format|
        format.html { redirect_to action: 'new' and return }
        file_error('Please Upload a valid file')
      end
    end

    order_upload = ImportOrder.new(@file)
    @processed_data = order_upload.process

    if order_upload.error_message
      respond_to do |format|
        file_error(order_upload.error_message)
        format.html { redirect_to action: 'new' and return }
      end
    end

    flash[:notice] = 'Successfully uploaded and processed the file.'
	end

end
