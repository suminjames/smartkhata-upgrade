require 'test_helper'
require "#{Rails.root}/app/globalhelpers/custom_date_module"

# This is for fiscal year 2073/74
class FloorsheetFlowTest < ActionDispatch::IntegrationTest
  include CustomDateModule
  include Devise::Test::IntegrationHelpers

  def setup
    set_host
    sign_in users(:user)
    set_fy_code_and_branch(7374, 1)

    @get_opening_balance_diff = lambda {
      get report_balancesheet_index_path
      assigns(:opening_balance_diff)
    }
  end

  test "floorsheet flow" do

    # Different scenario to test for

    # in terms of transaction type
    # buy, sell, both

    # in terms of number of transaction for a isin
    # one , many

    # in terms of companies traded
    # one, many

    # in terms of share amount
    # 0 - 2500, 2501 - 50000,
    # 50001 - 500000, 500001 - 1000000,
    # more than 1000001 (best to  include > 5000000)


    initial_opening_balance_diff = @get_opening_balance_diff

    assert_difference 'FileUpload.where(file_type: FileUpload::file_types[:floorsheet]).count', 1 do
      file = fixture_file_upload(Rails.root.join('test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport2073-08-13.xls'), 'text/xls')
      post import_files_floorsheets_path, file: file

      # debugging purpose
      write_to_html(response.body)
    end

    # verify if the vouchers created are correct



    final_opening_balance_diff = @get_opening_balance_diff

    # 1. CHECK BALANCE SHEET
    assert_equal initial_opening_balance_diff, final_opening_balance_diff

    # 2. CHECK TRIAL BALANCE
    date_bs = '2073-8-13' #floorsheet date
    get report_trial_balance_index_path(search_by:'date', search_term: date_bs)

    # scrape to find total: in the application, this is done by jquery
    ledger_rows = css_select('.ledger-group .ledger-single')
    opening_balance_dr = opening_balance_cr = dr_amount = cr_amount = closing_balance_dr = closing_balance_cr = 0
    ledger_rows.each do |row|
      #array of data # e.element? also possibly works
      data = row.children.select{|e| e.name=="td" }
      #remove commas and convert to numbers
      data.map!{|x| x.text.gsub(',','').to_f} #to_f

      opening_balance_dr += data[1]
      opening_balance_cr += data[2]
      dr_amount += data[3]
      cr_amount += data[4]
      closing_balance_dr += data[5]
      closing_balance_cr += data[6]
    end

    # Credits and debits in the grand total row should be equal
    [ [opening_balance_dr, opening_balance_cr],
      [dr_amount, cr_amount],
      [closing_balance_dr, closing_balance_cr] ].each { |a, b| assert_equal a.to_i, b.to_i }

    # need to verify this

    # # Check the amounts and closing balance are greater than zero
    # [dr_amount, closing_balance_cr].each { |v| assert_operator v, :>, 0 }

  end
end