# Notes:

# Test files integrity crucial: Several major aspects of the test are dependent on the specific test files
#                               currently located at test/fixtures/files/May10/(.xls && .csv)
#                               Be sure not to edit/remove those files

# Bills fixtures should be empty : Assuming no Bills fixtures present
#                                  makes the bills id start from one
#                                  rather than starting after the random number assigned to the fixtures.

# TODO maybe: calculate the bills count dynamically.. making the test work with different test files
require 'test_helper'
require "#{Rails.root}/app/globalhelpers/custom_date_module.rb"

class BasicAppFlowTest < ActionDispatch::IntegrationTest
  include CustomDateModule
  def setup
    # login as existing user
    lalchan = users(:user)
    post_via_redirect new_user_session_path, 'user[email]' => lalchan.email, 'user[password]' => 'password'
    assert_equal root_path, path
    assert_equal 'Signed in successfully.', flash[:notice]

    # DO calculate these from the test files END
    @purchase_bills_expected_count = 51
    @sales_bills_expected_count = 45

    # assume default
    @items_in_first_pagination = 20
  end

  test "the basic flow" do
    # Secure browsing!
    https!

    # Create a Bank
    assert_difference 'Bank.count', 1 do
      post banks_path, bank: { address: 'utopia', bank_code: 'TBH', contact_no: '999999999', name: 'The Bank' }
    end
    bank = assigns(:bank)
    assert_redirected_to bank_path(bank)

    # Create a Bank Account
    assert_difference 'BankAccount.count', 1 do
      post bank_accounts_path, bank_account: {bank_id: bank.id, account_number: 619, "default_for_receipt"=>"1", "default_for_payment"=>"1",
                                   "ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
    end
    bank_account = assigns(:bank_account)
    assert_redirected_to bank_account_path(bank_account)

    # Create a Cheque Entry
    assert_difference 'ChequeEntry.count', 10 do
      post cheque_entries_path, { bank_account_id: bank_account.id, start_cheque_number: 1, end_cheque_number: 10 }
    end
    assert_redirected_to cheque_entries_path

    # Upload a Floorsheet
    file = fixture_file_upload(Rails.root.join('test/fixtures/files/May10/BrokerwiseFloorSheetReport 10 May.xls'), 'text/xls')
    post import_files_floorsheets_path, file: file
    get files_floorsheets_path
    assert_not assigns(:file_list).empty?

    # Upload a Sales CM05
    file = fixture_file_upload(Rails.root.join('test/fixtures/files/May10/CM0518052016141937.csv'), 'text/csv')
    post import_files_sales_path, file: file
    sales_settlement_id = assigns(:sales_settlement_id)
    follow_redirect!
    assert_equal sales_settlement_path(sales_settlement_id), path
    assert_select 'a[href=?]', generate_bills_path(sales_settlement_id), text: 'Process the Settlement'
    # test pagination
    # select method 1
    inner_pagination_div = css_select 'div.pagination-per-page'
    inner_pagination_div_text = inner_pagination_div[0].text.gsub(/\s+/, "")
    assert_equal inner_pagination_div_text, 'Perpage50|Total69'
    assert_select 'ul.pagination' do
      assert_select 'li.active>a', text: '1'
      assert_select 'li>a', text: '2'
      assert_select 'li.next_page>a', text: 'Next ›'
      assert_select 'li.last.next>a', text: 'Last »'
    end

    # Process settlement
    get generate_bills_path(sales_settlement_id)
    assert_response :success
    assert_select 'h3', text: 'Bills generated Successfully'
    # verify bills count
    assert_equal Bill.find_by_bill_type('purchase').count, @purchase_bills_expected_count
    assert_equal Bill.find_by_bill_type('sales').count, @sales_bills_expected_count

    # Process bills
    # i. Sales bills
    get sales_bills_path
    # select method 2
    assert_match 'Displaying bills <b>1&nbsp;-&nbsp;20</b> of <b>45</b> in total', response.body

    # new_voucher_path_regex = /\/vouchers\/new\?bill_id=[0-9]{1,2}&amp;voucher_type=1/
    # bill_path_regex = /\/bills\/[0-9]{1,2}/
    # ! UNABLE TO WORKOUT REGEX !

    # check links
    sales_bills_starting_count = @purchase_bills_expected_count + 1
    # assert_select 'a[href^="/vouchers/new?bill_id="][href$="&voucher_type=1"]', {count:20, text: 'Process Bill'}
    sales_bills_ending_count_in_page = sales_bills_starting_count + @items_in_first_pagination - 1
    sales_bills_starting_count.upto(sales_bills_ending_count_in_page) do |bill_id|
      assert_select 'a[href=?]', new_voucher_full_path(bill_id), text: 'Process Bill'
      assert_select 'a[href=?]', bill_path(bill_id),        text: 'View'
    end

    # Payment voucher

    # debugger
    # NIL ERROR HERE:
    # get new_voucher_full_path(sales_bills_starting_count)
    get new_voucher_path(bill_id: sales_bills_starting_count, voucher_type: 1)
    assert_select 'h2.section-title', text: 'New Payment Voucher'
    form_objects = css_select 'form.simple_form.new_voucher'
    form_text = form_objects[0].text
    assert_contains ad_to_bs(Date.today).to_s, form_text

  end

  private
    # DO make the individual params/args instance variables if always the same END
    def generate_bills_path(sales_settlement_id)
      "#{generate_bills_sales_settlements_path}?id=#{sales_settlement_id}"
    end

    def sales_bills_path
      "#{bills_path}?utf8=%E2%9C%93&search_by=bill_type&search_term=sales&commit=Search"
    end

    def new_voucher_full_path(bill_id, voucher_type=1)
      "#{new_voucher_path}?bill_id=#{bill_id}&voucher_type=#{voucher_type}"
    end
end
