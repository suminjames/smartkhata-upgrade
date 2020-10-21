class Files::SysAdminTasksController < Files::FilesController
  def new
    @allowed_files_list = allowed_files
    authorize self
  end

  def import
    authorize self
    @file = params[:file]
    @file_type = params[:file_type]
    @allowed_files_list = allowed_files

    if @allowed_files_list.include? @file_type
      file_upload = "SysAdminServices::Import#{@file_type.camelize}".constantize.new(@file)
      file_upload.process

      @error = file_upload.error_message if file_upload.error_message
    else
      @error = "Invalid operation selected"
    end

    redirect_to new_files_sys_admin_task_path, flash: {error: @error} and return if @error
  end

  def file_upload_tasks(file, file_type)
  end

  def allowed_files
    %w[opening_balance payments_receipts customer_registrations bo_details].freeze
  end
end
