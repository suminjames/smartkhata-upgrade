class Pdf::PdfBankPaymentLetter < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(bank_payment_letter, current_tenant, print_in_letter_head)
    @bank_payment_letter = bank_payment_letter
    @current_tenant = current_tenant
    @print_in_letter_head = print_in_letter_head

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
      header unless @print_in_letter_head
      move_down(3)
      letter_top
      move_down(3)
      client_accounts_list
      move_down(8)
      letter_bottom
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

  def generate_page_number
    string = "page <page> of <total>"
    options = { :at => [bounds.right - 150, 0],
                :width => 150,
                :align => :right,
                :start_count_at => 1
    }
    number_pages string, options
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
    text "We hereby authorize you to disburse NRs #{arabic_number(@bank_payment_letter.settlement_amount)} in different accounts of our clients as mentioned in the list below."
  end

  def letter_bottom
    text "Please debit our Account No #{@bank_payment_letter.bank_account.account_number} held at your bank against the aforementioned total amount in this letter."
    br
    text 'Thank you.'
    br
    text "For #{current_tenant.full_name},"
    br
    br
    br
    # TODO(sarojk): Find a better way to do this so that new tenant won't have problem.
    case current_tenant.name
      when 'trishakti'
        signee_name = 'Tanka Prasad Gautam'
        designation = 'Executive Chairman'
      when 'dipshikha'
        signee_name = 'Bishnu Prasad Ojha'
        designation = 'Executive Chairman'
      else
        signee_name = ''
        designation = ''
    end
    text signee_name
    text designation

  end

  def client_accounts_list
    data = []
    th_data = ['S.N.',
               'Client Name',
               'Nepse Code',
               'Bank Name',
               "Bank\nBranch",
               "Bank\nAccount #",
               'Bill',
               "Amount\n(in NRs.)"
    ]
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
          p.ledger.client_account.bank_name,
          p.ledger.client_account.bank_address,
          p.ledger.client_account.bank_account,
          bills_str,
          arabic_number(p.amount)
      ]

    end
    table_width = page_width - 2
    column_widths = {0 => table_width * 0.5/12.0,
                     1 => table_width * 2/12.0,
                     2 => table_width * 1.2/12.0,
                     3 => table_width * 2.1/12.0,
                     4 => table_width * 1.6/12.0,
                     5 => table_width * 1.8/12.0,
                     6 => table_width * 1.3/12.0,
                     7 => table_width * 1.5/12.0,
    }
    table data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.column(0..6).style(:align => :center)
      t.column(7).style(:align => :right)
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
    hr
  end

end
