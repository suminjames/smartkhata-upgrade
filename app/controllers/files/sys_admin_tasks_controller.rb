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

      if file_upload.error_message
        @error = file_upload.error_message
      end
    else
      @error = "Invalid operation selected"
    end

    if @error
      redirect_to new_files_sys_admin_task_path, :flash => {:error => @error} and return
    end

  end

  def file_upload_tasks(file, file_type)

  end

  def allowed_files
    %w(opening_balance payments_receipts customer_registrations).freeze
  end


end
