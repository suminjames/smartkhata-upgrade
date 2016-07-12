class Reports::Pdf::ShareTransactionsReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(share_transactions, params, current_tenant, print_in_letter_head)
    @share_transactions = share_transactions
    @params = params
    @current_tenant = current_tenant
    @print_in_letter_head = print_in_letter_head

    @date = ad_to_bs Date.today

    @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
    @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?

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
      share_transactions_list
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
    if @client_account && @isin_info
      document_headings.push("Client-Company Report", "of \"#{@client_account.name.strip}\" for \"#{@isin_info.company.strip}\"")
      @file_name = "ClientCompany_ShareTransactionReport_#{@client_account.id}_#{@isin_info.id}_#{@date}"
    elsif @client_account
      document_headings.push("Client Wise Report", "\"#{@client_account.name.strip}\"")
      @file_name = "ClientWise_ShareTransactionReport_#{@client_account.id}_#{@date}"
    elsif @isin_info
      document_headings.push("Company Wise Report", "\"#{@isin_info.company.strip}\"")
      @file_name = "CompanyWise_ShareTransactionReport_#{@isin_info.id}_#{@date}"
    else # full report
      sub_heading = "All transactions"
      sub_heading << " of" if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present?}
      document_headings.push("Share Inventory Report", sub_heading)
      @file_name = "ShareTransactionReport_#{@date}"
    end

    table_data  = []
    document_headings.each do |heading|
      table_data << [
          heading
      ]
    end
    table_width = page_width - 2
    table table_data do |t|
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column_widths = {0 => table_width}
    end

    def share_transactions_list
      table_data = []
      th_data = ["SN.", "Date", "Transaction No.", "Company", "Bill No.", "Qty\nin", "Qty\nout", "Market\nRate", "Amount", "Commission"]
      table_data << th_data
      @share_transactions.each_with_index do |st, index|
        sn = index + 1
        date = ad_to_bs_string(st.date)
        contract_num = st.contract_no
        company = st.isin_info.name_and_code
        bill_num = st.bill.present? ? st.bill.full_bill_number : 'N/A'
        q_in = st.buying? ? arabic_number(st.quantity).to_i : ''
        q_out = st.selling? ? arabic_number(st.quantity).to_i : ''
        m_rate = arabic_number(st.isin_info.last_price.to_f)
        share_amt = arabic_number(st.share_amount.to_f)
        comm_amt = arabic_number(st.commission_amount.to_f)

        table_data << [
            sn,
            date,
            contract_num,
            company,
            bill_num,
            q_in,
            q_out,
            m_rate,
            share_amt,
            comm_amt
        ]
      end
      table_width = page_width - 2
      column_widths = {0 => table_width * 0.5/12.0,
                       1 => table_width * 1/12.0,
                       2 => table_width * 2/12.0,
                       3 => table_width * 2/12.0,
                       4 => table_width * 1.3/12.0,
                       5 => table_width * 0.7/12.0,
                       6 => table_width * 0.7/12.0,
                       7 => table_width * 1/12.0,
                       8 => table_width * 1/12.0,
                       9 => table_width * 1.5/12.0
      }
      table table_data do |t|
        t.header = true
        t.row(0).font_style = :bold
        t.row(0).size = 9
        t.column(0..6).style(:align => :center)
        t.column(5..9).style(:align => :right)
        t.row(0).style(:align => :center)
        t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
        t.column_widths = column_widths
      end
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
