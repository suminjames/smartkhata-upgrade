class Files::FilesController < ApplicationController
  # set the error message
  def file_error(message)
    flash.now[:error] = message
    @error = true
  end



  # return true if the floor sheet file itself is invalid
  def is_invalid_file(file, file_name_contains)
    puts file == nil
    puts file.original_filename
    puts (!file.original_filename.upcase.include? file_name_contains)
    puts file.original_filename.include? ".gz"
    file == nil || ((!file.original_filename.upcase.include? file_name_contains ) || (file.original_filename.include? ".gz"))
  end

  def convert_to_date(string)
    begin
      string.to_date
    rescue ArgumentError
      nil
    end
  end
end
