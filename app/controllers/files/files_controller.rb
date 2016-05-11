class Files::FilesController < ApplicationController
  # set the error message
  def file_error(message)
    flash.now[:error] = message
    # Preserves the flash even when redirecting(using redirect_to)
    # TODO: Make sure to discaard flash using flash.discard in relevant action(request) so that the flash doesn't persist more than one request.
    flash.keep
    @error = true
  end



  # return true if the floor sheet file itself is invalid (doesn't check integrity of the content inside the file, but only file name and the existence of the file)
  def is_invalid_file(file, file_name_contains = '')
    file == nil || ((!file.original_filename.upcase.include? file_name_contains.upcase ) || (file.original_filename.include? ".gz"))
  end

  def convert_to_date(string)
    begin
      string.to_date
    rescue ArgumentError
      nil
    end
  end
end
