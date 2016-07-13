class Reports::Excelsheet
  # To be used as a base class for individual excelsheet report generators!
  include CustomDateModule

  attr_reader :path
  attr_reader :error

  def type
    # Excelsheet File type needed for send_file
    "application/vnd.ms-excel"
  end

  def generated_successfully?
    # Returns true if no error
    @error.nil?
  end

  def data_present_or_set_error(data, err_msg=nil)
    # Returns true if data supplied is not empty
    err_msg ||= "No data to generate report!"
    if data.present?
      true
    else
      @error = err_msg
      false
    end
  end
end
