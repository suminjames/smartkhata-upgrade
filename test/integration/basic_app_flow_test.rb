# # Notes:
#
# # Test files integrity crucial: Several major aspects of the test are dependent on the specific test files
# #                               currently located at test/fixtures/files/May10/(.xls && .csv)
# #                               Be sure not to edit/remove those files
#
# # Omitted: group_leader_ledger_id, random: cheque number
#
# # Further work[maybe]:
# #          calculate the bills count dynamically.. making the test work with different test files?
#
require "#{Rails.root}/app/globalhelpers/custom_date_module"
require 'test_helper'

class BasicAppFlowTest < ActionDispatch::IntegrationTest
  include CustomDateModule
  include Devise::Test::IntegrationHelpers

  def setup
    # To prevent isin company Nil Error in bills#show
    Rake::Task["fetch_companies"].invoke
    # Rake::Task["update_isin_prices"].invoke

    # subdomain needed for current_tenant()
    set_host
    # Secure browsing!
    https!
    # login as existing user
    sign_in users(:user)

    # Set relevant fy code and branch id
    @fy_code = 7374
    set_fy_code_and_branch(7374, 1)

    # this might not be needed as bills on fixture wont get added anymore
    # factory girls setting perhaps

    # @purchase_bills_in_fixtures = Bill.purchase.count
    # @sales_bills_in_fixtures = Bill.sales.count

    # DO calculate these from the test files END
    # bill in (file + fixtures)
    @purchase_bills_expected_count = 2
    @sales_bills_expected_count = 4

    @additional_bank_id = Bank.first.id
    # Cash ledger expected in fixtures!
    @cash_ledger_id = Ledger.find_by!(name: "Cash").id

    # assume default pagination
    @items_in_first_pagination = 20

    # Sample date within the fiscal_year
    @sample_date = '2073-6-30'
    @date_today = ad_to_bs(Date.today).to_s
  end
#
  test "the basic flow" do
    ############################################# SECTION ONE ##########################################################

    puts "Creating Bank & accounts..."

    # --- 1. Add Bank ---
    assert_difference 'Bank.count', 1 do
      post banks_path, bank: { address: 'utopia', bank_code: 'TBH', contact_no: '999999999', name: 'The Bank' }
    end
    new_bank = assigns(:bank)
    assert_redirected_to bank_path(new_bank)

    # --- 1.1 Add Bank Account- of created bank & existing bank ---
    existing_bank = banks(:one)
    assert_difference 'BankAccount.by_branch_id.count', 2 do
      post bank_accounts_path, bank_account: {bank_id: new_bank.id, account_number: 619, bank_branch: "asd", "default_for_receipt"=>"1", "default_for_payment"=>"0",
                                   "ledger_attributes" => { group_id: 1, "ledger_balances_attributes" => [{ opening_balance: 500, opening_balance_type: 'dr'}]}}
      @bank_account_receipt = assigns(:bank_account)
      post bank_accounts_path, bank_account: {bank_id: existing_bank.id, account_number: 916, bank_branch: "asd", "default_for_receipt"=>"0", "default_for_payment"=>"1",
                                              "ledger_attributes" => { group_id: 1, "ledger_balances_attributes" => [{ opening_balance: 500, opening_balance_type: 'dr'}] }}
      @bank_account_payment = assigns(:bank_account)
    end
    assert_redirected_to bank_account_path(@bank_account_payment)


    ############################################### SECTION TWO ########################################################

    puts "Adding cheque entries..."
    # --- 2. Add Cheque Entries ---
    assert_difference 'ChequeEntry.count', 20 do
      post cheque_entries_path, { bank_account_id: @bank_account_receipt.id, start_cheque_number: 1, end_cheque_number: 20 }
    end

    assert_redirected_to cheque_entries_path('filterrific[by_bank_account_id]': @bank_account_receipt.id)


    ############################################# SECTION THREE ########################################################

    puts "Uploading Floorsheet with new client accounts..."
    # --- 3. Upload Floorsheet of date X ---
    file = fixture_file_upload(Rails.root.join('test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls'), 'text/xls')
    post import_files_floorsheets_path, file: file

    # As the file contains client accounts that are not in the db yet, floorsheet import is cancelled.
    expected_error_message = "FLOORSHEET IMPORT CANCELLED!New client accounts found in the file!Please manually create the client accounts for the following in the system first, before re-uploading the floorsheet.If applicable, please make sure to assign the correct branch to the client account so that billing is tagged to the appropriate branch."
    assert_select "div#flash_error", text: expected_error_message

    # Mimic manual creation of new client accounts in the file (that are also listed in the error page).
    new_client_accounts = assigns(:new_client_accounts)
    assert_not new_client_accounts.empty?
    client_account_size_before = ClientAccount.unscoped.all.size
    new_client_accounts.each do |new_client_account|
      ClientAccount.create(
          {
              :name => new_client_account[:client_name],
              :nepse_code => new_client_account[:client_nepse_code],
              :branch_id =>  branches(:one).id,
              :skip_validation_for_system => true
          }
      )
    end
    client_account_size_after = ClientAccount.unscoped.all.size
    assert_equal new_client_accounts.size, client_account_size_after - client_account_size_before

    # Redo the file upload.
    post import_files_floorsheets_path, file: file
    get files_floorsheets_path
    assert_not assigns(:file_list).empty?


    ############################################# SECTION FOUR #########################################################

    puts "Uploading corresponding CM05..."
    # --- 4. Upload CM05 of date X ---
    file = fixture_file_upload(Rails.root.join('test/fixtures/files/sales_cm/CM0502122016121554_test.csv'), 'text/csv')
    post import_files_sales_path, file: file, settlement_date: '2073-08-16'
    @nepse_settlement_id = assigns(:nepse_settlement_id)

    follow_redirect!
    assert_equal nepse_sale_settlement_path(@nepse_settlement_id), path
    assert_select 'input[type=hidden][name=id]', value: @nepse_settlement_id

    assert_select 'form[action=?]', generate_bills_nepse_settlements_path do
      assert_select 'button[type=submit]', text: 'Process the Settlement'
    end


    puts "Processing Settlement... Generating Bills"
    # --- 4.1 Process Settlement ---
    get generate_bills_nepse_settlements_path, {id: @nepse_settlement_id}
    assert_response :success
    assert_select 'h3', text: 'Bills generated Successfully'

    purchase_bills = Bill.purchase
    sales_bills =    Bill.sales
    # verify bills count
    # FIXME: The following two lines fail because of changes in 'default_scope' of bill.rb, which previously scoped by fy_code. Upon removal of scoping by fy_code, the bills from fixtures/bills.yml is also being picked up.
    assert_equal @purchase_bills_expected_count, purchase_bills.count
    assert_equal @sales_bills_expected_count, sales_bills.count

    bills_starting_id = Bill.first.id

    # 4 bills will be generated
    bills_ending_count_in_page = 4
    bills_starting_id.upto(bills_ending_count_in_page) do |bill_id|
      # assert_select 'a[href=?]', new_voucher_full_path(bill_id, 1), text: 'Process Bill' # no more
      assert_select 'a[href=?]', bill_path(bill_id), text: 'View'
    end



    ############################################# SECTION FIVE #########################################################

    # bill processing method has changed.
    # might be a good idea to move this test to elsewhere under bill integration test perhaps

    #
    #
    # puts "Settling bills"
    # bank_ledgers = Ledger.where.not(bank_account_id: nil).count
    # number_of_ledger_options_expected = bank_ledgers + 1 #cash_ledger
    #
    # sales_bills_starting_id = sales_bills.first.id
    #
    #
    # # Payment voucher
    # # --- 5.1 Process sales bills ---
    # get new_voucher_full_path(sales_bills_starting_id, 1)
    # # --- 5.1 - New payment voucher should be shown ---
    # assert_select 'h2.section-title', text: 'New Payment Voucher'
    # date_default_value = css_select("form.simple_form.new_voucher input[name='voucher[date_bs]']")[0]['value']
    # assert_equal @date_today, date_default_value
    #
    # # # This approach was discarded
    # # # used the autocomplete which uses ajax calls
    # # assert_select "input[name='voucher[desc]']", value: "Settled for Bill No: #{@fy_code}-#{sales_bills_starting_id}"
    # # assert_select '.voucher select#voucher_particulars_attributes_3_ledger_id' do
    # #   assert_select 'option', number_of_ledger_options_expected
    # #   # --- 5.1 - Default credit ledger should default to corresponding bank for sales ---
    # #   assert_select 'option[selected=selected]', {text:"Bank:#{@bank_account_payment.bank_name}(#{@bank_account_payment.account_number})",
    # #                                               value: @bank_account_payment.id.to_s}
    # # end
    #
    #
    # # --- 5.1 - On create ---
    #
    # # little bit scraping - payment voucher
    # first_particular_ledger_id, second_particular_ledger_id = [], []
    # first_particular_ledger_id[0], second_particular_ledger_id[0], payment_amount = scrape_ledger_ids_and_payment_amount
    #
    # # Cannot check the default cheque number, being an ajax call;
    # cheque_num = '8374'
    #
    # voucher = post_via_redirect_vouchers_path(1, nil, "#{sales_bills_starting_id}", false, first_particular_ledger_id[0], payment_amount, 'cr', cheque_num,
    #                                           second_particular_ledger_id[0], "Settled for Bill No: #{@fy_code}-#{sales_bills_starting_id}", true)
    # assert_equal voucher_path(voucher), path
    # assert_equal 'Voucher was successfully created.', flash[:notice]
    # # --- 5.1 - On create - incase of payment by bank, payment voucher is created
    # assert_select 'h3', 'Payment voucher Bank'
    # # approve
    # post finalize_payment_vouchers_path, {from_path: vouchers_path, id: "#{voucher.id}", approve: "approve"}
    #
    # assert_equal 'Payment Voucher was successfully approved', flash[:notice]
    # assert_redirected_to vouchers_path
    #
    # # --- 5.1 - On create -incase of payment by cash, normal voucher is created
    # get new_voucher_full_path(sales_bills_starting_id+1, 1)
    #
    # # little bit scraping again- payment voucher
    # first_particular_ledger_id[1], second_particular_ledger_id[1], payment_amount = scrape_ledger_ids_and_payment_amount
    #
    # # group_leader_ledger_id = css_select('input[name=group_leader_ledger_id]')[0]['value']
    # post_via_redirect_vouchers_path(1, nil, "#{sales_bills_starting_id+1}", false, first_particular_ledger_id[1], payment_amount, 'cr', '',
    #                                 second_particular_ledger_id[1], "Settled for Bill No: #{@fy_code}-#{sales_bills_starting_id}", true)
    #
    # # --- 5.1 - On create -incase of payment by cash, normal voucher is created
    # assert_select 'h4 u', 'PAYMENT'
    #
    # puts "Fetching Purchase bills & processing one..."
    # # --- 5. Go to bill list #purchase
    # get purchase_bills_path
    # assert_match "Displaying bills <b>1&nbsp;-&nbsp;#{@items_in_first_pagination}</b> of <b>#{@purchase_bills_expected_count}</b> in total", response.body
    #
    # # check links
    # # The purchase bill from fixture appears first, which is serially followed by other purchase bills.
    # # Thus although the fixture bill is not tested in ledgers, it does affect the bill listing here.
    #
    # # THIS BLOCK FAILS IN BULK TEST: LIKELY SORTING ISSUE
    # # purchase_bills_actual_starting_id = purchase_bills_starting_id - 1
    # # purchase_bills_ending_count_in_page = purchase_bills_actual_starting_id + @items_in_first_pagination - 1
    # # purchase_bills_actual_starting_id.upto(purchase_bills_ending_count_in_page) do |bill_id|
    # #   debugger #if css_select('a[href=?]', bill_path(bill_id)).empty?
    # #   assert_select 'a[href=?]', bill_path(bill_id),        text: 'View'
    # # end
    #
    # # Just check the presence of desired number of bill links
    # assert_select 'a[href^=?]', '/bills/', text: 'View', count: @items_in_first_pagination
    #
    # # --- 5.2 Process purchase bills ---
    # get new_voucher_full_path(purchase_bills_starting_id, 2)
    # # --- 5.2 - Receipt voucher should be shown with narration and amount ---
    # assert_select 'h2.section-title', text: 'New Receipt Voucher'
    # date_default_value = css_select("form.simple_form.new_voucher input[name='voucher[date_bs]']")[0]['value']
    # assert_equal @date_today, date_default_value
    # assert_select "input[name='voucher[desc]']", value: "Settled for Bill No: #{@fy_code}-#{purchase_bills_starting_id}"
    #
    # assert_select '.voucher select#voucher_particulars_attributes_0_ledger_id' do
    #   assert_select 'option', number_of_ledger_options_expected
    #   # --- 5.2 - Default debit ledger should default to corresponding bank for sales ---
    #   assert_select 'option[selected=selected]', {text:"Bank:#{@bank_account_receipt.bank_name}(#{@bank_account_receipt.account_number})",
    #                                               value: @bank_account_receipt.id.to_s}
    # end
    #
    # # little bit scraping -receipt voucher
    # first_particular_ledger_id[2], second_particular_ledger_id[2], payment_amount = scrape_ledger_ids_and_payment_amount
    # cheque_num = '3750'
    #
    # voucher = post_via_redirect_vouchers_path('2', nil, "#{purchase_bills_starting_id}", false, first_particular_ledger_id[2], payment_amount, 'dr', cheque_num,
    #                                           second_particular_ledger_id[2], "Settled for Bill No: #{@fy_code}-#{purchase_bills_starting_id}", true)
    # settlement_ids = voucher.settlements.pluck(:id)
    # assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    # # --- 5.2 - On create - receipt should be created with relevant information ---
    # assert_select 'h4 u', 'RECEIPT'
    # assert_match payment_amount, response.body
    # assert_match Bank.find(@additional_bank_id).name, response.body
    #
    # get sales_bills_path
    # # Verify no process link in bill list- no more shown initially
    # # assert_select 'a[href=?]', new_voucher_full_path(sales_bills_starting_id, 1),   {count:0, text: 'Process Bill'}
    # # assert_select 'a[href=?]', new_voucher_full_path(sales_bills_starting_id+1, 1), {count:0, text: 'Process Bill'}
    # # --- 5.3 Verify in Ledgers for ledgers affected in step 5.1 & 5.2 ---
    # ledger_index_to_particulars_count = [3, 4, 11]
    # puts "Checking texts & links in corresponding ledgers..."
    # second_particular_ledger_id.each do |ledger_id|
    #   get ledger_path(ledger_id)
    #   assert_response :success
    #
    #
    #   # TODO(dorado) The below line fails
    #   # particulars_num = ledger_index_to_particulars_count[second_particular_ledger_id.index(ledger_id)]
    #   # debugger
    #   # assert_match "Displaying <b>all #{particulars_num}</b> particulars", response.body
    #
    #   # # test links!
    #   # link_objects = css_select '.box-body.ledger.ledger-single a[data-remote=true]'
    #   #
    #   # link_objects.each do |link_obj|
    #   #   # Add more extended tests here?
    #   #   link = link_obj['href']
    #   #   get link
    #   #   assert_response :success
    #   #   unless link.include? 'cheque_entries'
    #   #     header_text_initial = case link
    #   #     when /vouchers/
    #   #       'Voucher'
    #   #     when /bills/
    #   #       'Bill'
    #   #     when /settlements/
    #   #       'Settlement'
    #   #     end
    #   #     header_text = "#{header_text_initial} Details"
    #   #     # Not h3.modal-title, coz we're checking direct link, not ajax
    #   #     assert_select 'h2.section-title', header_text
    #   #   else
    #   #     # No cheque details header in direct link!
    #   #     assert_match 'Pay against this cheque to', response.body
    #   #   end
    #   # end
    # end


    ############################################# SECTION SIX ##########################################################

    puts "Fetching Client ledgers..."
    # --- 6. Client Ledgers ---
    get client_ledgers_path
    assert_response :success
    client_ledgers_count = Ledger.find_all_client_ledgers.count

    puts "Processing ledger & verifying..."
    # --- 6.1 Process ledger & verify ---

    # .THIRD(): Ignore two client ledgers in fixtures
    ledger = Ledger.find_all_client_ledgers.third
    client_account_id = ledger.client_account_id
    get ledger_path(ledger.id)
    assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger'}
    assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills'}
    assert_select 'h3', 'User One ( SK1 )'

    # Before processing, should show the unprocessed bill(s) list.
    get client_bills_path(client_account_id)
    bill_ids = []
    css_select('input[type=checkbox][name="bill_ids[]"]').each do |bill_id_obj|
      bill_ids << bill_id_obj['value']
    end
    post_via_redirect process_selected_bills_path, {
      "bill_ids" => bill_ids,
      "client_account_id"=> client_account_id,
     }


    assert_equal new_voucher_path(bill_ids:bill_ids, client_account_id: client_account_id), request.original_fullpath
    assert_select 'h2.section-title', text: 'New Receipt Voucher'

    # scraping!
    cr_ledger_id, dr_ledger_id, payment_amount = scrape_ledger_ids_and_payment_amount
    cheque_num = '5234'
    bill_numbers = "#{@fy_code}-" + bill_ids.join(", #{@fy_code}-")

    assert_equal payment_amount.to_s, "293358.69"

    voucher = post_via_redirect_vouchers_path('2', "#{client_account_id}", bill_ids, false, cr_ledger_id, payment_amount, 'dr', cheque_num,
                                              dr_ledger_id, "Settled for Bill No: #{bill_numbers}", true)

    write_to_html(response.body)
    settlement_ids = voucher.payment_receipts.pluck(:id).uniq
    assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    assert_select 'h4 u', 'RECEIPT'

    # rest of the select tests already done above
    # fetch the same ledger again
    get ledger_path(ledger.id)
    assert_select('a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger', count: 0})
    # assert_select 'a[href=?]', client_bills_path(client_account_id),                                           {text: 'Process Selected Bills', count: 0}


    # # This is not of utmost importance for now
    # puts "Clearing ledger & verifying..."
    # # --- 6.2 Clear ledger & verify ---
    # # .FOURTH(): Ignore two ledgers in fixtures + one ledger used in the previous step
    # ledger = Ledger.find_all_client_ledgers.fourth
    # client_account_id = ledger.client_account_id
    # get ledger_path(ledger.id)
    # assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger'}
    # assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills'}
    #
    # if bills_processed_directly
    #   # Get this dynamically!!!
    #   voucher_type = 'payment'
    # else
    #   voucher_type = voucher.voucher_type
    # end
    # get new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id)
    # assert_select 'h2.section-title', "New #{voucher_type.capitalize} Voucher"
    #
    # # scraping!
    # first_particular_ledger_id[4], second_particular_ledger_id[4], payment_amount = scrape_ledger_ids_and_payment_amount
    # cheque_num = '5344'
    # voucher_type_code, transaction_type_first = case voucher_type
    # when 'payment' then [1, 'cr']
    # when 'receipt' then [2, 'dr']
    # end
    #
    # voucher = post_via_redirect_vouchers_path(voucher_type_code, "#{client_account_id}", nil, true, first_particular_ledger_id[4], payment_amount, transaction_type_first, cheque_num,
    #                                           second_particular_ledger_id[4], 'Settled with ledger balance clearance', true)
    # case voucher.voucher_type
    # when 'payment'
    #   assert_equal voucher_path(voucher), path
    #   assert_select 'h3', 'Payment voucher Bank'
    #   post finalize_payment_vouchers_path, {from_path: vouchers_path, id: "#{voucher.id}", approve: "approve"}
    #   assert_equal 'Payment Voucher was successfully approved', flash[:notice]
    # when 'receipt'
    #   settlement_ids = voucher.settlements.pluck(:id)
    #   assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    #   assert_select 'h4 u', 'RECEIPT'
    # end
    # # rest of the select tests already done above
    # # fetch the same ledger again
    # get ledger_path(ledger.id)
    # assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger',           count: 0}
    # assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills', count: 0}



    ############################################# SECTION SEVEN ########################################################

    puts "Creating different types of vouchers & verifying..."
    # --- 7. Voucher creation --- Create all types of vouchers ---
    # --- 7.1 Journal with out Bank ---
    get new_voucher_path
    assert_block_in_voucher('New Journal Voucher', 0)

    # no select used now
    # autocomplete.. need to be tested on the controller part

    # ledger_options = css_select 'select#voucher_particulars_attributes_0_ledger_id option'
    # assert_equal 'Cash', ledger_options[0].text  # first option should be cash

    # Select some random person to credit

    test_client_ledger =  Ledger.find_all_client_ledgers.first

    credited_ledger_id = test_client_ledger.id
    credited_ledger_name = test_client_ledger.name
    payment_amount = "500.00"
    voucher = post_via_redirect_vouchers_path(0, nil, nil, "false", @cash_ledger_id, payment_amount, 'dr', '',
                                              credited_ledger_id, '', false, true)
    assert_equal voucher_path(voucher), path
    assert_equal 'Voucher was successfully created.', flash[:notice]
    assert_select 'h2.section-title', 'Voucher Details'

    [credited_ledger_name, 'Cash', payment_amount, "Voucher Date: #{@sample_date}", "#{@fy_code}-#{voucher.voucher_number}"].each do |item|
      assert_match item, response.body
    end

    # --- 7.2 Journal with Bank Account credit ---
    get new_payment_voucher_path
    # credited_bank_account_ledger_id, credited_ledger_id, credited_ledger_name =
    #   assert_block_in_voucher('New Payment Voucher', "Bank:#{@bank_account_payment.bank.name}(#{@bank_account_payment.account_number})", 'cr')

    payment_amount = "500.00"
    cheque_num = "948" #random
    voucher = post_via_redirect_vouchers_path(1, nil, nil, "false", @bank_account_payment.ledger.id, payment_amount, 'cr', cheque_num,
                                              credited_ledger_id, '', true, true)
    settlement_ids = voucher.payment_receipts.pluck(:id).uniq

    assert_equal voucher_path(voucher), path
    assert_select 'h3', 'Payment voucher Bank'

    [credited_ledger_name, payment_amount, cheque_num, "Voucher Date: #{@sample_date}"].each do |item|
      assert_match item, response.body
    end

     # --- 7.3 Journal with Bank Account debit ---
    get new_receipt_voucher_path
    debited_bank_account_ledger_id = @bank_account_receipt.ledger.id

    voucher = post_via_redirect_vouchers_path(2, nil, nil, "false", debited_bank_account_ledger_id, payment_amount, 'dr', '',
                                              credited_ledger_id, '', true, true)
    settlement_ids = voucher.payment_receipts.pluck(:id).uniq
    assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    assert_select 'h4 u', 'RECEIPT'

    # receipt_num = Settlement.find(settlement_ids[0]).id
    settlement = Settlement.find(settlement_ids[0])
    receipt_code = "#{settlement.branch.code}-#{settlement.settlement_number}"
    [credited_ledger_name, payment_amount, "Date: #{@sample_date}", "Receipt No: #{receipt_code}"].each do |item|
      assert_match item, response.body
    end

    puts '"BASIC" app flow Test Successfully completed!!!'
  end

  private

  def sales_bills_path
    # "#{bills_path}?utf8=???&search_by=bill_type&search_term=sales&commit=Search"
    bills_path(utf8: '%E2%9C%93', search_by: 'bill_type', search_term: 'sales', commit: 'Search')
  end

  def purchase_bills_path
    bills_path(utf8: '%E2%9C%93', search_by: 'bill_type', search_term: 'purchase', commit: 'Search')
  end

  def new_voucher_full_path(bill_id, voucher_type)
    new_voucher_path(bill_ids: ["#{bill_id}"], voucher_type: "#{voucher_type}")
  end

  def ledger_full_path(ledger_id)
    ledgers_path(utf8: '%E2%9C%93', search_by: 'ledger_name', search_term: "#{ledger_id}", commit: 'Search')
  end

  def client_ledgers_path
    ledgers_path(show: 'all_client')
  end

  def new_receipt_voucher_path
    new_voucher_path(voucher_type: '2')
  end

  def new_payment_voucher_path
    new_voucher_path(voucher_type: '1')
  end

  def client_bills_path(client_acc_id)
    bills_path(search_by: 'client_id', search_term: "#{client_acc_id}")
  end

  def post_via_redirect_vouchers_path(voucher_type, client_account_id, bill_id, clear_ledger,
                                      ledger_one_id, payment_amount, transaction_one_type, cheque_num, ledger_two_id, desc,
                                      voucher_settlement_type_default=false, payment_mode_default=false)
    transaction_two_type = transaction_one_type == 'cr'? 'dr':'cr'
    date = @sample_date
    params =
      {"voucher_type"=> voucher_type,
       # "client_account_id"=> client_account_id,
       "clear_ledger" => clear_ledger,
       "voucher"      =>
         {"date_bs"               => date,
         "particulars_attributes" =>
           {"0"=>
             {"ledger_id"         => ledger_one_id,
             "amount"             => payment_amount,
             "transaction_type"   => transaction_one_type,
             "cheque_number"      => cheque_num,
             "additional_bank_id" => @additional_bank_id
            },
           "3"=>
             {"ledger_id"         => ledger_two_id,
             "amount"             => payment_amount,
             "transaction_type"   => transaction_two_type,
             # "cheque_number"      =>"",
             "additional_bank_id" => @additional_bank_id
            }
          },
         "desc"                    => desc
        }
        # "vendor_account_id"       =>"",
        # "group_leader_ledger_id"  =>,
      }
      if bill_id
        bill_id_key = case bill_id
        when Array then 'bill_ids'
        else 'bill_id'
        end
        params[bill_id_key] = bill_id
      end
      params["client_account_id"] = client_account_id if client_account_id
      params["voucher_settlement_type"] = "default" if voucher_settlement_type_default
      params["payment_mode"] = "default" if payment_mode_default
      post vouchers_path, params
      voucher = assigns(:voucher)
      follow_redirect!
      voucher
  end

  # defunct perhaps
  def scrape_ledger_ids_and_payment_amount
    ledger_one_id = css_select('select#voucher-financial-ledger-combobox option[selected=selected]')[0]['value']
    ledger_two_id = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    amount = css_select('input#voucher_particulars_attributes_3_amount')[0]['value']
    [ledger_one_id, ledger_two_id, amount]
  end

  def assert_block_in_voucher(title, preselected_text_or_count, first_transaction_type=nil)
    assert_response :success
    assert_select 'h2.section-title', text: title
    assert_select 'form.simple_form.new_voucher input#voucher_date_bs', value: @date_today
    param = if preselected_text_or_count.is_a? String then :text else :count end
    assert_select 'select#voucher_particulars_attributes_0_ledger_id option[selected=selected]', {param => preselected_text_or_count}
    if first_transaction_type
      second_transaction_type = first_transaction_type == 'cr' ? 'dr': 'cr'
      # first transaction type dr/cr & disabled
      assert_select 'select[disabled=disabled]#voucher_particulars_attributes_0_transaction_type' do
        assert_select 'option[selected=selected]', {text: first_transaction_type}
      end
      # second transaction type cr/dr & disabled
      assert_select 'select[disabled=disabled]#voucher_particulars_attributes_3_transaction_type' do
        assert_select 'option[selected=selected]', {text: second_transaction_type}
      end
      bank_account_ledger_id = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
      ledger_options = css_select 'select#voucher_particulars_attributes_3_ledger_id option'
      # Select a person to credit
      credited_ledger_id = ledger_options[10]['value']
      credited_ledger_name = ledger_options[10].text
      [bank_account_ledger_id, credited_ledger_id, credited_ledger_name]
    end
  end
end