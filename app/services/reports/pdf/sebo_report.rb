class Reports::Pdf::SeboReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper
  include ShareTransactionsHelper

  def initialize(share_transactions, params, current_tenant,fiscal_year, print_in_letter_head=nil)
    @share_transactions = share_transactions
    @params = params
    @current_tenant = current_tenant
    @fiscal_year = fiscal_year
    @print_in_letter_head = print_in_letter_head || false

    if @print_in_letter_head
      top_margin = 38.mm
      bottom_margin = 11.mm
    else
      top_margin = 12
      bottom_margin = 18
    end

    super(top_margin: top_margin, right_margin: 18, bottom_margin: bottom_margin, left_margin: 18, page_layout: :landscape, page_size: "A3")

    draw
  end

  def draw
    font_size(7) do
      move_down(3)
      # repeat(:all) do
      company_header unless @print_in_letter_head
      # end
      report_header
      move_down(3)
      securities_flows_list
      generate_page_number
    end
  end

  def page_width
    # 558
    1155
  end

  def page_height

    # 770
    1118
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
    # report_headings = report_headings_for_securities_flow(@params, @is_securities_balance_view)
    # table_data = []
    # report_headings.each do |heading|
    #   table_data << [heading]
    # end
    # table_width = page_width - 2
    # column_widths = {
    #     0 => table_width * 12/12.0,
    # }
    # table table_data do |t|
    #   t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
    #   t.column(0).style(:align => :center)
    #   t.column(0).font_style = :bold
    #   t.column_widths = column_widths
    # end

    # text "Sebo Report.pdf"

  end


  def securities_flows_list
    table_data = []
    # table_data.unshift %w(id name address)
    th_data = [
        "S.no",
        "Company Name",
        "Buying Trans",
        "Buying Qty",
        "Buying Amt",
        "Sebo Comm",
        "Comm. Amt",
        "Nepse Comm",
        "TDS",
        "Amount to Nepse",
        "Selling Trans",
        "Selling Qty",
        "Selling Amt",
        "Comm Amt",
        "TDS",
        "Sebo Comm",
        "Nepse Comm",
        "Capital Gain",
        "Amt From Nepse",
        "Total Trans",
        "Total Qty",
        "Total Amt"
    ]
    table_data << th_data
    buy_transaction_count = 0
    buy_quantity = 0
    buying_amount = 0
    buy_sebo_comm = 0
    buy_comm_amount = 0
    buy_nepse_comm = 0
    buy_tds = 0
    amount_to_nepse = 0
    selling_transaction_count = 0
    selling_quantity = 0
    selling_amount = 0
    selling_comm_amount = 0
    selling_tds = 0
    selling_sebo_comm = 0
    selling_nepse_comm = 0
    total_cgt = 0
    amount_from_nepse = 0
    total_transaction_count = 0
    total_quantity = 0
    total_amount = 0

    @share_transactions.each_with_index do |share_transaction, index|
      td_data = [
        index + 1,
        share_transaction.isin_info.company,
        share_transaction["buy_transaction_count"],
        share_transaction["buy_quantity"],
        monetary_decimal(share_transaction["buying_amount"]),
        monetary_decimal(share_transaction["buy_sebo_comm"]),
        monetary_decimal(share_transaction["buy_comm_amount"]),
        monetary_decimal(share_transaction["buy_nepse_comm"]),
        monetary_decimal(share_transaction["buy_tds"]),
        monetary_decimal(share_transaction["amount_to_nepse"]),
        share_transaction["selling_transaction_count"],
        share_transaction["selling_quantity"],
        monetary_decimal(share_transaction["selling_amount"]),
        monetary_decimal(share_transaction["selling_comm_amount"]),
        monetary_decimal(share_transaction["selling_tds"]),
        monetary_decimal(share_transaction["selling_sebo_comm"]),
        monetary_decimal(share_transaction["selling_nepse_comm"]),
        monetary_decimal(share_transaction["total_cgt"]), 
        monetary_decimal(share_transaction["amount_from_nepse"]),
        share_transaction["total_transaction_count"],
        share_transaction["total_quantity"],
        monetary_decimal(share_transaction["total_amount"])
      ]
      table_data << td_data
      buy_transaction_count+=share_transaction["buy_transaction_count"]
      buy_quantity+=share_transaction["buy_quantity"]
      buying_amount+=share_transaction["buying_amount"]
      buy_sebo_comm+=share_transaction["buy_sebo_comm"]
      buy_comm_amount+=share_transaction["buy_comm_amount"]
      buy_nepse_comm+=share_transaction["buy_nepse_comm"]
      buy_tds+=share_transaction["buy_tds"]
      amount_to_nepse+=share_transaction["amount_to_nepse"]
      selling_transaction_count+=share_transaction["selling_transaction_count"]
      selling_quantity+=share_transaction["selling_quantity"]
      selling_amount+=share_transaction["selling_amount"]
      selling_comm_amount+=share_transaction["selling_comm_amount"]
      selling_tds+=share_transaction["selling_tds"]
      selling_sebo_comm+=share_transaction["selling_sebo_comm"]
      selling_nepse_comm+=share_transaction["selling_nepse_comm"]
      total_cgt+=share_transaction["total_cgt"]
      amount_from_nepse+=share_transaction["amount_from_nepse"]
      total_transaction_count+=share_transaction["total_transaction_count"]
      total_quantity+=share_transaction["total_quantity"]
      total_amount+=share_transaction["total_amount"]

    end
    td_data_total = [
      " ",
      "Totals:", 
      buy_transaction_count,
      buy_quantity,
      monetary_decimal(buying_amount),
      monetary_decimal(buy_sebo_comm),
      monetary_decimal(buy_comm_amount),
      monetary_decimal(buy_nepse_comm),
      monetary_decimal(buy_tds),
      monetary_decimal(amount_to_nepse),
      selling_transaction_count,
      selling_quantity,
      monetary_decimal(selling_amount),
      monetary_decimal(selling_comm_amount),
      monetary_decimal(selling_tds),
      monetary_decimal(selling_sebo_comm),
      monetary_decimal(selling_nepse_comm),
      monetary_decimal(total_cgt),
      monetary_decimal(amount_from_nepse),
      total_transaction_count,
      total_quantity,
      monetary_decimal(total_amount)
    ]
    table_data << td_data_total

    table_width = page_width - 2
    column_widths = {
        0 => table_width * 0.5/22.0,   #sn
        1 => table_width * 2/22.0,     #company
        2 => table_width * 0.7/22.0,   #buy trans
        3 => table_width * 0.7/22.0,   #buy qty
        4 => table_width * 1.3/22.0,   #buy amt
        5 => table_width * 0.9/22.0,   #sebo comm
        6 => table_width * 1/22.0,     #comm amt
        7 => table_width * 0.9/22.0,   #buy nepse comm 
        8 => table_width * 0.8/22.0,   #buy tds
        9 => table_width * 1.3/22.0,   #amt to nepse
        10 => table_width * 0.8/22.0,  #sell trans
        11 => table_width * 0.8/22.0,  #sell qty
        12 => table_width * 1.3/22.0,  #sell amt
        13 => table_width * 1/22.0,    #sell comm amt
        14 => table_width * 0.8/22.0,  #sell tds
        15 => table_width * 0.9/22.0,  #sebo comm
        16 => table_width * 0.9/22.0,  #sell nepse comm
        17 => table_width * 1/22.0,    #captital gain
        18 => table_width * 1.3/22.0,  #amt frm nepse
        19 => table_width * 0.8/22.0,  #total trans
        20 => table_width * 1/22.0,    #total qty
        21 => table_width * 1.3/22.0,  #total amt
    }

    #:header => true as an option repeats first row(header) of an array on subsequent pages
    table(table_data, header: true) do |t|
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column(1).style(:align => :left)
      t.column(2).style(:align => :center)
      t.column(3).style(:align => :center)
      t.column(4).style(:align => :right)
      t.column(5).style(:align => :right)
      t.column(6).style(:align => :right)
      t.column(7).style(:align => :right)
      t.column(8).style(:align => :right)
      t.column(9).style(:align => :right)
      t.column(10).style(:align => :center)
      t.column(11).style(:align => :center)
      t.column(12).style(:align => :right)
      t.column(13).style(:align => :right)
      t.column(14).style(:align => :right)
      t.column(15).style(:align => :right)
      t.column(16).style(:align => :right)
      t.column(17).style(:align => :right)
      t.column(18).style(:align => :right)
      t.column(19).style(:align => :right)
      t.column(20).style(:align => :right)
      t.column(21).style(:align => :right)
      t.row(0).style(:align => :center, :size => 9, :background_color => "C0C0C0")
      t.row(0).font_style = :bold
      # t.row(-1).style(:borders => [:bottom, :top, :right, :left]) #:background_color => "C0C0C0"
      t.row(-1).columns(1..20).borders = [:bottom, :top]
      t.row(-1).columns(0).borders = [:bottom, :left, :top]
      t.row(-1).columns(21).borders = [:right, :bottom, :top]
      t.row(-1).columns(1).style(:align => :right)
      t.row(-1).columns(1).font_style = :bold
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
      text "<b>#{@current_tenant.address}</b>", :inline_format => true, :size => 11
      text "<b>Phone: #{@current_tenant.phone_number}</b>", :inline_format => true, :size => 10
      text "<b>Fax: #{@current_tenant.fax_number}</b>", :inline_format => true, :size => 10
      # text "PAN: #{@current_tenant.pan_number}"
      if @params.present?
        date_from = @params[:by_date_from].present? ? @params[:by_date_from] : '*'
        date_to = @params[:by_date_to].present? ? @params[:by_date_to] : '*'
        text "<b>Date From #{date_from}" + "   " + "Date To #{date_to}"  + "                  " +"                                    "+ "Fiscal Year #{@fiscal_year}</b>", :inline_format => true, :size => 10 
      elsif 
        text "<b>Fiscal Year #{@fiscal_year}</b>", :inline_format => true, :size => 10, :align => :center
      end
    end
    hr
  end

  def file_name
    "SeboReport.pdf"
  end

end
