class Pdf::PdfBankPaymentLetter < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(bank_payment_letter, current_tenant)
    super(top_margin: 12, right_margin: 38, bottom_margin: 18, left_margin: 18)

    @bank_payment_letter = bank_payment_letter
    @current_tenant = current_tenant

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      header
      hr
      move_down(3)
      letter_top
      move_down(3)
      client_accounts_list
      move_down(8)
      letter_bottom
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

  def letter_top
    text "Date: #{@bank_payment_letter.created_at.strftime("%Y-%m-%d")}", :align => :right
    br
    text 'The Manager'
    text "#{@bank_payment_letter.bank_account.bank_name}"
    text "#{@bank_payment_letter.bank_account.bank.address}"
    br
    text 'Dear Sir/Madam,'
    br
    text "We hereby authorize you to disburse Rs #{arabic_number(@bank_payment_letter.settlement_amount)} in different accounts of our clients as mentioned in the list below."
  end

  def letter_bottom
    text "Please debit our Account No #{@bank_payment_letter.bank_account.account_number} held at your bank against the aforementioned total amount in this letter."
    br
    text 'Thank you.'
    br
    text 'For Trishakti Securities Public Limited,'
    br
    br
    br
    text 'Tanka Prasad Gautam'
    text 'Executive Chairman'
  end

  def client_accounts_list
    @bank_payment_letter
    data = []
    th_data = ['S.N.', 'Client Name', 'Nepse Code', 'Bank Details', 'Bill', 'Amount']
    data << th_data
    @bank_payment_letter.particulars.each_with_index do |p, index|

      bills_str = ''
      p.bills.each do |bill|
        if bill.client_account_id == p.ledger.client_account_id
          bills_str += "#{bill.fy_code}-#{bill.bill_number}\n"
        end
      end

      data << [
          index + 1,
          p.ledger.client_account.name,
          p.ledger.client_account.nepse_code,
          "#{p.ledger.client_account.bank_name}\n#{p.ledger.client_account.bank_account}\n#{p.ledger.client_account.bank_address}",
          bills_str,
          arabic_number(p.amount)
      ]

    end
    table_width = page_width - 2
    column_widths = {0 => table_width * 0.5/12.0,
                     1 => table_width * 3/12.0,
                     2 => table_width * 1.5/12.0,
                     3 => table_width * 3.5/12.0,
                     4 => table_width * 1.5/12.0,
                     5 => table_width * 2/12.0,
    }
    table data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.column(5).style(:align => :right)
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column_widths = column_widths
    end
  end

  def header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(9)) do
      text "<b>#{@current_tenant.full_name}</b>", :inline_format => true, :size => 11
      text "#{@current_tenant.address}"
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
  end

end
