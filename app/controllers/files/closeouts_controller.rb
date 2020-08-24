class Files::CloseoutsController < Files::FilesController
  before_action -> {authorize self}

  def new
    @closeout_type = params[:type] == 'debit' ? 'debit' : 'credit'
  end

  def import
    # authorize self
    @file = params[:file]
    @closeout_type = params[:type] == 'debit' ? 'debit' : 'credit'

    file_error("Please Upload a valid file") and return if (is_invalid_file(@file))

    closeout_upload = ImportCloseOut.new(@file, @closeout_type, current_user, @selected_branch_id)
    closeout_upload.process
    @processed_data = closeout_upload.processed_data

    if closeout_upload.error_message
      file_error(closeout_upload.error_message)
      return
    end

  end
end
