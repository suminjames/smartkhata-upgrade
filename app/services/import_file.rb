class ImportFile
  attr_reader :status_code, :nepse_settlement_id, :error_message, :processed_data

  def initialize(file)
    @file = file
    @status_code = "FL0000"
    @error_message = nil
    @processed_data = []
  end

  def process
    raise NotImplementedError
  end


  def extract_csv(file)
    CSV.foreach(file.path, :headers => true) do |row|
      @processed_data << row.to_hash
    end
  end

  def extract_xls(file)
    raise NotImplementedError
  end

  def extract_xlsx(file)
    raise NotImplementedError
  end

  # open the corresponding file
  def open_file(file)
    case File.extname(file.original_filename)
      when ".csv" then
        extract_csv(file)
      when ".xls" then
        extract_xls(file)
      when ".xlsx" then
        extract_xlsx(file)
      # else raise "Unknown file type: #{file.original_filename}"
      else
        @error_message = "Unknown file type: #{file.original_filename}"
    end
  end

  def import_error(message)
    @error_message = message
  end

end
