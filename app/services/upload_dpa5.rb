class UploadDpa5
  attr_reader :status_code

  def initialize(file)
    @file = file
    @status_code = "FL0000"
  end

  def get_status
    @status_code
  end

  def process
    @processed_data = []
    # assign a date for fallback.
    @report_date = '1-Aug-2015'
    # read the file at once

    if (!@file.original_filename.include? "DPA5") || (@file.original_filename.include? ".gz")
      @status_code = "FL0001"
      return
    end

    content = @file.is_a?(StringIO) ? @file.read : File.read(@file.path)

    # file can have multiple reports concatenated
    # in case of multiple reports concatenated \r\n07END~ is added.
    # in case of normal files it will not affect as the content_data will have a single element.
    content_data = content.split("00END~\r\n")
    content_data.each do |f|
      process_single_file(f) unless f.empty?
    end

    @processed_data
  end

  def process_single_file(content)
    content = content.split("\r\n")
    single_record = []
    content.each { |x| single_record << x.split("~") }

    # verify file
    # verify_file(content[0])
    date_records = Set.new
    single_record.each do |y|
      extract(y)
      date_records.add(@report_date)
    end
    # extract(single_record[9])

    date_records.each do |date|
      # create a entry in the database
      FileUpload.find_or_create_by!(file_type: FileUpload.file_types[:dpa5], report_date: date.to_date)
    end
  end

  def extract(data)
    ActiveRecord::Base.transaction do
      record = ClientAccount.where(boid: data[0], dp_id: data[59])
                   .first_or_create do |account|
        account.skip_validation_for_system = true
      end

      client_type = get_client_type(data[2])
      # record = ClientAccount.where("REPLACE(name, ' ', '') = ? AND REPLACE(father_mother, ' ', '')= ? AND REPLACE(granfather_father_inlaw, ' ', '') = ?", data[11].tr(' ','').upcase, data[99].tr(' ', '').upcase, data[105].tr(' ', '').upcase).first
      #
      #
      #
      # if record.present?
      #   record.update( email: data[90].downcase)
      #   @report_date = data[110]
      #   @processed_data << record
      # end
      # # @processed_data << data

      record.update(boid: data[0],
                    date: data[8].to_date,
                    name: data[11],
                    address1: data[12],
                    address1_perm: data[13],
                    address2: data[14],
                    address2_perm: data[15],
                    address3: data[16],
                    address3_perm: data[17],
                    city: data[18],
                    city_perm: data[19],
                    state: data[20],
                    state_perm: data[21],
                    country: data[22],
                    country_perm: data[23],
                    phone: data[26],
                    phone_perm: data[27],
                    customer_product_no: data[58],
                    dp_id: data[59],
                    dob: data[60],
                    sex: data[61],
                    nationality: data[62],
                    stmt_cycle_code: data[63],
                    ac_suspension_fl: data[68],
                    profession_code: data[72],
                    income_code: data[76],
                    electronic_dividend: data[79],
                    dividend_curr: data[81],
                    email: data[90].downcase,
                    father_mother: data[99],
                    citizen_passport: data[100],
                    granfather_father_inlaw: data[105],
                    purpose_code_add: data[108],
                    add_holder: data[109],
                    client_type: client_type)
      #
      # @report_date = data[110]
      @processed_data << record
      # # @processed_data << data
      # @processed_data
    end
  end

  def verify_file(data); end

  def get_client_type(type)
    client_type = case type.upcase
      when "CORPORATE"
        ClientAccount.client_types[:corporate]
      else
        ClientAccount.client_types[:individual]
                  end
    client_type
  end
end
