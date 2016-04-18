class Files::SalesController < Files::FilesController
  @@file_name_contains = "CM05"
  def index

  end
  def new
    # new
    @file_list = SalesSettlement.order("settlement_date desc").limit(10);
  end

	def import
		# authorize self
		@file = params[:file];

    # grab date from the first record
    file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

    payout_upload = ImportPayout.new(@file)
    payout_upload.process

    if payout_upload.error_message
      @processed_data = payout_upload.processed_data
      file_error(payout_upload.error_message)
      return
    end

    # else redirect to settlement path
    redirect_to sales_settlement_path(payout_upload.sales_settlement_id) and return
	end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
