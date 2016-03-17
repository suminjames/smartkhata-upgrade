class Files::Dpa5Controller < ApplicationController
	# before_action :authenticate_user!
	# after_action :verify_authorized

	@@file = FileUpload::FILES[:dpa5];

	def new
		# authorize self
		file = FileUpload::FILES[:dpa5];
		@file_list = FileUpload.where(file: file).order("report_date desc").limit(10);
		if (@file_list.count > 1)
			if((@file_list[0].report_date-@file_list[1].report_date).to_i > 1)
				flash.now[:error] = "There is more than a day difference between last 2 reports.Please verify"
			end
		end
	end

	def import
		# authorize self
		@file = params[:file];
		if @file == nil
			flash.now[:error] = "Please Upload a valid file"
			@error = true
		else
			upload = UploadDpa5.new(@file)
			@processed_data = upload.process
			if upload.get_status ==  "FL0001"
				flash.now[:error] = "Please Upload a valid file"
				@error = true
			elsif upload.status_code == "FL0002"
				flash.now[:error] = "File you have uploaded is taking long time to process. Contact Support"

				@error = true
			end
		end
	end

	def index
		# authorize self
		@file_list = FileUpload.where(file: @@file)
                    .order("report_date DESC")
	end
end
