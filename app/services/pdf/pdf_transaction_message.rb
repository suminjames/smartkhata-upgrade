class Pdf::PdfTransactionMessage < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(date_ad, client_account, current_tenant)
    super(top_margin: 12, right_margin: 38, bottom_margin: 18, left_margin: 18)

    @date_ad = date_ad
    @client_account = client_account
    @current_tenant = current_tenant

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      header
      hr
      move_down(3)
      client_information
      move_down(3)
      share_transactions_list
      move_down(8)
      isin_abbreviation_index
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

  def share_transactions_list
    share_transactions = ShareTransaction.where(client_account_id: @client_account.id, date: @date_ad)
    data = []
    th_data = ['S.N.', 'Contract No.', 'Type', 'ISIN', 'Quantity', 'Rate', 'Amount']
    data << th_data
    share_transactions.each_with_index do |share_transaction, index|
      # TODO(sarojk): Ask subash whether raw_quantity or quanity of share_transaction to be shown?
      data << [
          index + 1,
          share_transaction.contract_no,
          share_transaction.transaction_type.titleize,
          share_transaction.isin_info.isin,
          share_transaction.quantity,
          share_transaction.share_rate,
          share_transaction.share_amount
      ]
    end
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/12.0,
                     1 => table_width * 3/12.0,
                     2 => table_width * 1/12.0,
                     3 => table_width * 1/12.0,
                     4 => table_width * 2/12.0,
                     5 => table_width * 2/12.0,
                     6 => table_width * 2/12.0,
    }
    table data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.columns(0..5).style(:align => :center)
      t.column(6).style(:align => :right)
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column_widths = column_widths
    end
  end

  def client_information
    text "Transactions of <b>#{@client_account.name} (#{@client_account.nepse_code})</b> dated <b>#{@date_ad}</b>.", :inline_format => true
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

  def isin_abbreviation_index
    unique_isins = Set.new()
    share_transactions = ShareTransaction.where(client_account_id: @client_account.id, date: @date_ad)
    share_transactions.each do |share_transaction|
      unique_isins.add(share_transaction.isin_info)
    end
    isin_abbreviation_index_str = ''
    unique_isins.each do |isin|
      isin_abbreviation_index_str += isin.isin + ': ' + isin.company + ' | '
    end
    # strip the trailing '| ' and return
    text '<b><i>ISIN Index</i></b>:', :inline_format => true
    text isin_abbreviation_index_str.slice(0, isin_abbreviation_index_str.length-2)
  end

end
