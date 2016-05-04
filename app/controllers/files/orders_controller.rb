class Files::OrdersController < Files::FilesController
  helper_method :is_active_sub_menu_option

  @@file_type = FileUpload::file_types[:orders]
  @@file_name_contains = "order"

  def index
    #default landing action for '/files/orders'
    if params[:search_by].blank?
      respond_to do |format|
        format.html { redirect_to files_orders_path(show:'report', search_by: "client_name") }
      end
      return
    end

    if params[:show] == 'report'
      if params[:search_by] == 'client_name'
        @orders = []
        #TODO
        if params[:commit] == 'Search'
          #@orders = Order.find_by_client_name(params[:search_term])
          @orders = Order.includes(:client_account).where(client_account:{id:1}).references(:client_accounts)
          #p "YO"
          #p @orders
          #@orders
        end 
      end

      if params[:search_by] == 'order_number'
        @orders = []
        if params[:search_term] == 'order_number'
          @orders
        end
      end

      if params[:search_by] == 'all_orders'
      @orders = Order.all.page(params[:page]).per(20).order("order_date_time desc")
      end

    end
    if params[:show] != 'report'
      @file_list = FileUpload.where(file_type: @@file_type).page(params[:page]).per(20).order("report_date desc")
    end
  end

	def new
    @file_list = FileUpload.where(file_type: @@file_type).order("report_date desc").limit(10);
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

  def is_active_sub_menu_option(option)
    return params[:search_by] == option
  end

end
