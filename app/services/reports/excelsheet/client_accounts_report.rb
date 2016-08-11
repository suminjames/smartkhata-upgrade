class Reports::Excelsheet::ClientAccountsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Name", "Nepse Code", "BOID", "Phone", "Email"]

  def initialize(client_accounts, params, current_tenant)
    super(client_accounts, params, current_tenant)
    if params && @params[:by_client_id].present?
      @client_account = ClientAccount.find_by(id: @params[:by_client_id])
    end

    generate_excelsheet if params_valid?
  end

  # Not needed anymore as this check is run in the view.
  # def data_present?
  #   data_present_or_set_error(@client_accounts, "Atleast one client account is needed for exporting!")
  # end

  def params_valid?
    # checks only for existence of client when client id given.
    # Returns true for nil param
    if @params && (@params[:filterrific].present? && !@client_account)
      @error = "Specified client account not present!"
      false
    else
      true
    end
  end

  def prepare_document
    # Adds document headings and sets the filename, before the real data table is inserted.
    extra_infos = "_"
    sub_headings = []
    if @client_account
      sub_headings << "of \"#{@client_account.name.strip}\""
      extra_infos << "single_"
    end
    if @params && @params[:client_filter].present?
      sub_headings << "filter: #{@params[:client_filter].gsub('_', ' ')}"
      extra_infos << "filtered_"
    end
    sub_headings << "All clients" if sub_headings.empty?

    add_document_headings_base("Client Account Register", *sub_headings)
    @file_name = "ClientAccountRegister_#{extra_infos}#{@date}"
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    normal_style_row = [@styles[:normal_center], *[@styles[:wrap]]*2].insert(2, *[@styles[:normal_style]]*3)
    striped_style_row = [@styles[:striped_center], *[@styles[:wrap_striped]]*2].insert(2, *[@styles[:striped_style]]*3)
    @client_accounts.each_with_index do |c, index|
      sn = index + 1
      name = c.name.titleize
      nepse = c.nepse_code
      boid = c.boid
      contract_nums =  c.commaed_contact_numbers
      email = c.email

      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [sn, name, nepse, boid, contract_nums, email], style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns

    # Fixed width for first column which is elongated by document headers
    # s.n. and email fields
    @sheet.column_widths 6, nil, nil, nil, nil, 30

    # auto width not working well for single client account
    @sheet.column_info.second.width = 30 if @client_account
  end
end
