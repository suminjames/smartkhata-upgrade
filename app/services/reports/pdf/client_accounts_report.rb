class Reports::Pdf::ClientAccountsReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(client_accounts, params, current_tenant)
    @client_accounts = client_accounts
    @current_tenant = current_tenant
    @params = params

    @print_in_letter_head = false
    @date = ad_to_bs Date.today

    if @print_in_letter_head
      top_margin = 38.mm
      bottom_margin = 11.mm
    else
      top_margin = 12
      bottom_margin = 18
    end

    super(top_margin: top_margin, right_margin: 38, bottom_margin: bottom_margin, left_margin: 18)

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      company_header unless @print_in_letter_head
      report_header
      move_down(3)
      client_accounts_list
      move_down(3)
      generate_page_number
    end
  end

  def page_width
    558
  end

  def page_height
    770
  end

  def col (unit)
    unit / 12.0 * page_width
  end

  def hr
    pad_bottom(3) do
      stroke_horizontal_rule
    end
  end

  def br
    text "\n"
  end

  def report_header
    # Adds document headings and returns the filename conditionally
    document_headings = []
    document_headings.push("Client Accounts Register")

    report_date = ad_to_bs Date.today
    document_headings.push("Report Date: #{report_date}")

    if @params && @params[:client_filter].present?
      filter_used = @params[:client_filter]
      document_headings.push("Filter: #{ClientAccount.pretty_string_of_filter_identifier(filter_used)}")
    end

    table_data  = []
    document_headings.each do |heading|
      table_data << [
          heading
      ]
    end
    table_width = page_width - 2
    table table_data do |t|
      t.row(0..1).font_style = :bold
      t.row(0..1).size = 9
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column_widths = {0 => table_width}
    end
  end

  def client_accounts_list
    table_data = []
    th_data = ["SN.", "Name", "Nepse Code", "BOID", "Mobile", "Phone", "Phone Permanent", "Email", "Bank","Bank Address", "Bank Account"]
    table_data << th_data
    @client_accounts.each_with_index do |client_account, index|
      sn = index + 1
      name = client_account.name.titleize
      nepse_code = client_account.nepse_code
      boid = client_account.boid
      mobile_number = client_account.mobile_number
      phone = client_account.phone
      phone_perm = client_account.phone_perm
      email = client_account.email
      bank_name = client_account.bank_name
      bank_address = client_account.bank_address
      bank_account = client_account.bank_account

      table_data << [
          sn,
          name,
          nepse_code,
          boid,
          mobile_number,
          phone,
          phone_perm,
          email,
          bank_name,
          bank_address,
          bank_account
      ]
    end

    table_width = page_width - 2
    column_widths = {0 => table_width * 0.7/17.5,
                     1 => table_width * 1.4/17.5,
                     2 => table_width * 1.2/17.5,
                     3 => table_width * 1.9/17.5,
                     4 => table_width * 1.6/17.5,
                     5 => table_width * 1.6/17.5,
                     6 => table_width * 1.6/17.5,
                     7 => table_width * 1.8/17.5,
                     8 => table_width * 1.8/17.5,
                     9 => table_width * 1.8/17.5,
                     10 =>table_width * 1.8/17.5
    }
    table table_data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.row(1..-1).size = 8
      t.row(0).style(:align => :center)
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column_widths = column_widths
    end
  end

  def generate_page_number
    string = "page <page> of <total>"
    options = { :at => [bounds.right - 150, 0],
                :width => 150,
                :align => :right,
                :start_count_at => 1
    }
    number_pages string, options
  end

  def company_header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(9)) do
      text "<b>#{@current_tenant.full_name}</b>", :inline_format => true, :size => 11
      text "#{@current_tenant.address}"
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
    hr
  end

end
