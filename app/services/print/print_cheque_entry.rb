class Print::PrintVoucher< Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(voucher, particulars, bank_account, cheque, current_tenant)
    super(top_margin: 1, right_margin: 18, bottom_margin: 18, left_margin: 18)

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
    578
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
      t.cell_style = {:border_width => 0, :padding => [0,2,0,0], :align => :left}
      t.column_widths = column_widths
      t.column(1).style(:align => :right)
    end
  end

  def payment_bank_particular_list
    data= [
        ["Account Head", "Particular", "Cheque Number", "Amount"]
    ]

    @particulars.each do |particular|
      particular_desc =  ''
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

      data << [particular.ledger.name, particular_desc, @cheque, arabic_number(particular.amount) ]
    end

    table_width = page_width - 2
    column_widths = {0 => table_width * 3/12.0, 1 => table_width * 4/12.0, 2 => table_width * 3/12.0, 3 => table_width * 2/12.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 1, :padding => [1,2,1,2], :align => :left}
      t.row(0).font_style = :bold
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
      t.cell_style = {:border_width => 1, :padding => [1,2,1,2], :align => :left}
      t.row(0).font_style = :bold
      t.column_widths = column_widths
    end

  end

  def bill_no_row
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(4)) do
      text "Bill No: #{@bill.formatted_bill_number}"
    end
    bounding_box([col(4), row_cursor], :width => col(5)) do
      text "Bill Date: #{@bill.formatted_bill_dates["ad"]} (#{@bill.formatted_bill_dates["bs"]})"
    end
    bounding_box([col(9), row_cursor], :width => col(3)) do
      text "Fiscal Year: #{@bill.formatted_fy_code}", :align => :right
    end
  end

  def header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(3)) do
      text "#{@current_tenant.full_name}"
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
    table(data, :column_widths => column_widths, :cell_style => {:border_width => 0, :padding => [0,2,0,0], :align => :center})
  end

  def bill_message
    text @bill.formatted_bill_message
  end

  def customer_details_row
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(6)) do
      data =[
          ["Customer:", @bill.formatted_client_name],
          ["NEPSE Code:", @bill.client.nepse_code]
      ]
      table(data, :column_widths => {0 => 100} , :cell_style => {:border_width => 0, :padding => [0,2,0,0], :align => :left})
    end
    bounding_box([col(6), row_cursor], :width => col(6)) do
      data =[
          ["Contact No.:", @bill.formatted_client_phones['secondary']],
          ["", @bill.formatted_client_phones['secondary']]
      ]
      table(data, :column_widths =>{0 => 100}, :position => :right, :cell_style => {:border_width => 0, :padding => [0,2,0,2], :align => :right})
    end
  end

  def calculation_section
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(6)) do
      tr_data = [
          ["Share Amount:", @bill.formatted_net_share_amount],
          ["SEBO Commission:", @bill.formatted_net_sebo_commission],
          ["Net Commission Amount:", @bill.formatted_net_commission],
          ["DP Fee:", @bill.formatted_net_dp_fee],
          ["Capital Gain:", @bill.formatted_net_cgt],
          ["Net Receivable Amount:", @bill.formatted_net_receivable_amount],
          ["Net Payable Amount:", @bill.formatted_net_payable_amount]
      ]
      if @bill.bill_type == 'purchase'
        tr_data.delete_at(4)
        tr_data.delete_at(5)
      end
      if @bill.bill_type == 'sales'
        tr_data.delete_at(5)
      end
      table(tr_data, :cell_style => {:border_width => 0, :padding => [0,2,0,2], :align => :right})
    end

    bounding_box([col(6)+col(1), row_cursor], :width => col(5)) do
      data = [
          ["Clearance Date:", @bill.formatted_clearance_dates['ad'] +" (" + @bill.formatted_clearance_dates['bs']  +")"],
          ["Transaction Date:", @bill.formatted_transaction_dates['ad'] +" (" + @bill.formatted_transaction_dates['bs']  +")"]
      ]
      table(data, :position => :right, :cell_style => {:border_width => 0, :padding => [0,2,0,2], :align => :right})

      move_down(30)

      text "_" * 35, :align => :center
      text "(Authorized Signature)", :align => :center
      text @current_tenant.full_name, :align => :center
      text "Broker Code No.: #{@current_tenant.broker_code}", :align => :center
      text "Nepal Stock Exchange", :align => :center
    end
  end

  def share_transactions_section

    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(12)) do
      data = []

      th_data = ["Transaction No", "No of Shares", "Company Code", "Share Rate", "Base Price", "Amount", "Commission", "Commission Amount", "Capital Gain Tax"]
      if @bill.bill_type == 'purchase'
        th_data.delete_at(4)
        th_data.delete_at(7)
      end

      data << th_data
      @bill.formatted_group_same_isin_same_rate_transactions.each do | formatted_share_transaction |
        row_data = [
            formatted_share_transaction[:contract_no],
            formatted_share_transaction[:raw_quantity].to_s + "(" + formatted_share_transaction[:raw_quantity_description] + ")",
            formatted_share_transaction[:isin],
            formatted_share_transaction[:share_rate],
            formatted_share_transaction[:base_price],
            formatted_share_transaction[:share_amount],
            formatted_share_transaction[:commission_rate],
            formatted_share_transaction[:commission_amount],
            formatted_share_transaction[:capital_gain]
        ]
        if @bill.bill_type == 'purchase'
          row_data.delete_at(4)
          row_data.delete_at(7)
        end
        data << row_data
      end

      table_width = page_width

      if @bill.bill_type == 'purchase'
        column_widths = {0 => table_width * 0.26, 1 => table_width * 0.20, 2 => table_width * 0.09 , 3 => table_width * 0.09 , 5 => table_width * 0.12 , 6 => table_width * 0.13 , 7 => table_width * 0.11 }
      else  # if @bill.bill_type == 'sales'
        column_widths = {0 => table_width * 0.25, 1 => table_width * 0.17, 2 => table_width * 0.07 , 3 => table_width * 0.07 , 4 => table_width * 0.07 , 5 => table_width * 0.10 , 6 => table_width * 0.09 , 7 => table_width * 0.09 , 8 => table_width * 0.09  }
      end
      table(data, :header => true, :column_widths => column_widths, :cell_style => {:size => 8, :padding => [2,2,2,2], :align => :center}, :width => table_width)
    end
  end

end
