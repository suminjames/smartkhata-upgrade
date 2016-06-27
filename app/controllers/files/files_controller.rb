class Files::FilesController < ApplicationController
  # set the error message
  def file_error(message)
    flash.now[:error] = message
    @error = true
  end

  # return true if the upload file itself is invalid  by only checking for file name validity and existence of the file. It doesn't check integrity of the content inside the file.
  def is_invalid_file(file, file_name_contains = '')
    file == nil || ((!file.original_filename.upcase.include? file_name_contains.upcase) || (file.original_filename.include? ".gz"))
  end

end
