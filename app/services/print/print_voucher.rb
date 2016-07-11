class Print::PrintVoucher< Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(voucher, particulars, bank_account, cheque, current_tenant)
    super(top_margin: 12, right_margin: 38, bottom_margin: 18, left_margin: 18)

    @voucher = voucher
    @particulars = particulars
    @bank_account = bank_account
    @cheque = cheque
    @current_tenant = current_tenant

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      header
      hr
      voucher_details
      move_down(8)
      if is_payment_bank?
        payment_bank_particular_list
      else
        non_payment_bank_particular_list
      end
      if is_payment_bank?
        move_down(35)
        signature_fields
      end
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

  def is_payment_bank?
    @voucher.is_payment_bank
  end

  def voucher_details
    if is_payment_bank?
      text 'Payment Voucher (Bank)', :size => 10
    end

    cell_0_1_data = ''
    cell_1_1_data = ''

    if is_payment_bank?
      cell_1_1_data = "Cr Account Name: #{@bank_account.account_number} #{@bank_account.bank_name}"
    else
      if @voucher.desc.present?
        cell_0_1_data = "Description: #{@voucher.desc}"
      end
    end
    data = [
        ["Voucher Number: #{@voucher.voucher_code} #{@voucher.fy_code}-#{@voucher.voucher_number}", "Voucher Date : #{@voucher.date_bs}"],
        [cell_0_1_data, cell_1_1_data]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/2.0, 1 => table_width * 1/2.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0], :align => :left}
      t.column_widths = column_widths
      t.column(1).style(:align => :right)
    end
  end

  def payment_bank_particular_list
    data= [
        ["Account Head", "Particular", "Cheque Number", "Amount"]
    ]

    @particulars.each do |particular|
      particular_desc = ''
      if @voucher.formatted_description.size > 0
        particular desc += "Being paid to #{particular.ledger.name} for"
        @voucher.formatted_description.each do |b|
          particular_desc += "Bill : #{b[0]} Amount: #{b[1]} | "
        end
        # Remove the trailing | and space
        particular_desc = particular_desc[0...-2]
      else
        particular_desc += @voucher.desc.present? ? "#{@voucher.desc}" : "Being paid to #{particular.ledger.name}"
      end

      data << [particular.ledger.name, particular_desc, @cheque, arabic_number(particular.amount)]
    end

    table_width = page_width - 2
    column_widths = {0 => table_width * 3/12.0, 1 => table_width * 4/12.0, 2 => table_width * 3/12.0, 3 => table_width * 2/12.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 1, :padding => [1, 2, 1, 2], :align => :left}
      t.row(0).font_style = :bold
      t.columns(0..-1).borders = [:left]
      t.columns(-1).borders = [:left, :right]
      t.rows(0).borders = [:top, :bottom, :left, :right]
      t.rows(-1).borders = [:bottom, :left, :right]
      t.column_widths = column_widths
    end
  end

  def non_payment_bank_particular_list
    data= [
        ["Ledger Details", "Dr", "Cr"]
    ]

    @particulars.each do |particular|
      dr_desc = (particular.dr?) ? arabic_number(particular.amount) : ""
      cr_desc = (particular.cr?) ? arabic_number(particular.amount) : ""
      data << [particular.ledger.name, dr_desc, cr_desc]
    end

    table_width = page_width - 2
    column_widths = {0 => table_width * 6/12.0, 1 => table_width * 3/12.0, 2 => table_width * 3/12.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 1, :padding => [1, 2, 1, 2], :align => :left}
      t.row(0).font_style = :bold
      t.columns(0..-1).borders = [:left]
      t.columns(-1).borders = [:left, :right]
      t.rows(0).borders = [:top, :bottom, :left, :right]
      t.rows(-1).borders = [:bottom, :left, :right]
      t.column_widths = column_widths
    end

  end

  def header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(9)) do
      text "<b>#{@current_tenant.full_name}<b>", :inline_format => true, :size => 9
      text "#{@current_tenant.address}"
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
  end

  def signature_fields
    data = [
        ["_" * 30, "_" * 30, "_" * 30],
        ["Prepared by", "Approved by", "Received by"]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/3.0, 1 => table_width * 1/3.0, 2 => table_width * 1/3.0}
    table(data, :column_widths => column_widths, :cell_style => {:border_width => 0, :padding => [0, 2, 0, 0], :align => :center})
  end

end
