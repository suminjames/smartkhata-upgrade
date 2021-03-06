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
      when ".csv"
        extract_csv(file)
      when ".xls"
        extract_xls(file)
      when ".xlsx"
        extract_xlsx(file)
      # else raise "Unknown file type: #{file.original_filename}"
      else
        @error_message = "Unknown file type: #{file.original_filename}"
    end
  end

  def import_error(message, log_error_to_db =  false)
    @error_message = message
    log_error_file if log_error_to_db
    # needed for early break
    true
  end


  def log_error_file
    true
  end
end
