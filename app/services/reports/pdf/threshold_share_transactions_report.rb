class Reports::Pdf::ThresholdShareTransactionsReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(share_transactions, params, current_tenant, print_in_letter_head)
    @share_transactions = share_transactions
    @current_tenant = current_tenant
    @print_in_letter_head = print_in_letter_head

    @date = ad_to_bs Date.today

    if params
      @params = params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
    end

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
      share_transactions_list
      move_down(3)
      signee_information
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

  def signee_information
    table_data = [
        ['Signature of reporter', ':'],
        ['Name', ':'],
        ['Designation', ':'],
        ['Phone', ": #{@current_tenant.phone_number}"],
        ['Email', ':'],
        ['Fax', ": #{@current_tenant.fax_number}"],
        ['Date', ':'],
    ]
    table_width = page_width - 2
    column_widths = {
        0 => table_width * 3/12.0,
        1 => table_width * 6/12.0
    }
    t = make_table table_data do |t|
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column_widths = column_widths
    end

    if (cursor - t.height) < 0
      start_new_page
    end

    t.draw
  end

  def report_header
    table_data = [
        ['Annexure 2'],
        ['Details of transactions above threshold in the indexed company.'],
        ["Indexed company name: #{@current_tenant.full_name}"]
    ]
    table_width = page_width - 2
    column_widths = {
        0 => table_width * 12/12.0,
    }
    table table_data do |t|
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column(0).font_style = :bold
      t.column_widths = column_widths
    end

  end


  def share_transactions_list
    table_data = []
    th_data = [
        "SN.",
        "Name of\n Buyer/Seller",
        "Occupation",
        "Branch\n(if any)",
        "Transaction\nDate",
        "Transaction\nType",
        "Transaction\nAmount",
        "Source\nof\n Fund",
        "Remarks",
    ]
    table_data << th_data
    @share_transactions.each_with_index do |share_transaction, index|
      table_data << [
          index + 1,
          share_transaction.client_account.name,
          share_transaction.client_account.profession_code,
          "",
          ad_to_bs_string(share_transaction.date),
          share_transaction.transaction_type.titleize,
          arabic_number(share_transaction.net_amount),
          "",
          "",
      ]

    end
    table_width = page_width - 2
    column_widths = {
        0 => table_width * 0.8/12.0,
        1 => table_width * 2/12.0,
        2 => table_width * 1.6/12.0,
        3 => table_width * 1.0/12.0,
        4 => table_width * 1.2/12.0,
        5 => table_width * 1.2/12.0,
        6 => table_width * 1.6/12.0,
        7 => table_width * 1.3/12.0,
        8 => table_width * 1.3/12.0,
    }
    table table_data do |t|
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :right)
      t.column(4).style(:align => :right)
      t.column(5).style(:align => :right)
      t.column(6).style(:align => :right)
      t.row(0).style(:align => :center)
      t.row(0).font_style = :bold
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
