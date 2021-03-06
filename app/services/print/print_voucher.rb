class Print::PrintVoucher < Prawn::Document
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
      move_down(35)
      signature_fields
    end
  end

  def page_width
    558
  end

  def page_height
    770
  end

  def col(unit)
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
    text 'Payment Voucher (Bank)', size: 10 if is_payment_bank?

    cell_0_1_data = ''
    cell_1_1_data = ''

    cell_1_1_data = "Cr Account Name: #{@bank_account.account_number} #{@bank_account.bank_name}" if is_payment_bank?
    cell_0_1_data = "Description: #{@voucher.desc}" if @voucher.desc.present? && @voucher.desc.length < 200
    data = [
      ["Voucher Number: #{@voucher.voucher_code} #{@voucher.fy_code}-#{@voucher.voucher_number}", "Voucher Date : #{@voucher.date_bs}"],
      [cell_0_1_data, cell_1_1_data]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1 / 2.0, 1 => table_width * 1 / 2.0}
    table data do |t|
      t.header = true
      t.cell_style = {border_width: 0, padding: [0, 2, 0, 0], align: :left}
      t.column_widths = column_widths
      t.column(1).style(align: :right)
    end
  end

  def payment_bank_particular_list
    data = [
      ["Account Head", "Particular", "Cheque Number", "Amount"]
    ]

    total_particular_amount = 0
    @particulars.each do |particular|
      particular_desc = ''
      if particular.bills.by_client_id(particular.ledger.client_account_id).count > 0
        particular_desc += "Being paid to #{particular.ledger.name} for"
        particular.bills.by_client_id(particular.ledger.client_account_id).each do |bill|
          particular_desc += "Bill : #{bill.fy_code}-#{bill.bill_number} Amount: #{arabic_number(bill.net_amount)} | "
        end
        # Remove the trailing | and space
        particular_desc = particular_desc[0...-2]
      else
        paid_to = particular.cheque_entries.first.beneficiary_name if particular.cheque_entries.first.present?
        paid_to ||= particular.ledger.name
        particular_desc += particular.description.presence || "Being paid to #{paid_to}"
      end
      # A payment voucher can come with particulars that don't have corresponding cheque entries.
      cheque_number = particular.try(:cheque_entries).try(:first).try(:cheque_number) || ""
      data << [particular.ledger.name, particular_desc, cheque_number, arabic_number(particular.amount)]
      total_particular_amount += particular.amount
    end
    total_row = [{content: 'Total Amount', colspan: 3}, arabic_number(total_particular_amount)]
    data << total_row

    table_width = page_width - 2
    column_widths = {0 => table_width * 3 / 12.0, 1 => table_width * 4 / 12.0, 2 => table_width * 3 / 12.0, 3 => table_width * 2 / 12.0}
    table data do |t|
      t.header = true
      t.cell_style = {border_width: 0.1, padding: [2, 2, 2, 2], align: :left}
      t.style(t.columns(0..-1).rows(0..-1), borders: %i[top bottom left right])
      t.style(t.row(0), align: :center, font_style: :bold)
      t.style(t.row(0).column(3), align: :center)
      t.row(-1).font_style = :bold_italic
      t.columns(2).style(align: :center)
      t.columns(3).style(align: :right)
      t.rows(-1).style(align: :right)
      t.column_widths = column_widths
    end
  end

  def non_payment_bank_particular_list
    data = [
      ["Ledger Details", "Particular", "Dr", "Cr"]
    ]

    total_debit_amount = 0
    total_credit_amount = 0

    @particulars.each do |particular|
      dr_desc = particular.dr? ? arabic_number(particular.amount) : ""
      cr_desc = particular.cr? ? arabic_number(particular.amount) : ""
      data << [particular.ledger.name, particular.description, dr_desc, cr_desc]
      if particular.dr?
        total_debit_amount += particular.amount
      else
        total_credit_amount += particular.amount
      end
    end

    total_row = [{content: 'Total Amount', colspan: 2}, arabic_number(total_debit_amount), arabic_number(total_credit_amount)]
    data << total_row

    table_width = page_width - 2
    column_widths = {0 => table_width * 4 / 12.0, 1 => table_width * 4 / 12.0, 2 => table_width * 2 / 12.0, 3 => table_width * 2 / 12.0}
    table data do |t|
      t.header = true
      t.cell_style = {border_width: 1, padding: [1, 2, 1, 2], align: :left}
      t.row(0).font_style = :bold
      t.columns(0..-1).borders = [:left]
      t.columns(-1).borders = %i[left right]
      t.rows(0).borders = %i[top bottom left right]
      t.rows(-1).borders = %i[top bottom left right]
      t.column_widths = column_widths
    end
  end

  def header
    row_cursor = cursor
    bounding_box([0, row_cursor], width: col(9)) do
      text "<b>#{@current_tenant.full_name}<b>", inline_format: true, size: 9
      text @current_tenant.address.to_s
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
    column_widths = {0 => table_width * 1 / 3.0, 1 => table_width * 1 / 3.0, 2 => table_width * 1 / 3.0}
    table(data, column_widths: column_widths, cell_style: {border_width: 0, padding: [0, 2, 0, 0], align: :center})
  end
end
