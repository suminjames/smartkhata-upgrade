# Notes:

# Test files integrity crucial: Several major aspects of the test are dependent on the specific test files
#                               currently located at test/fixtures/files/May10/(.xls && .csv)
#                               Be sure not to edit/remove those files

# Bills fixtures should be empty : Assuming no Bills fixtures present
#                                  makes the bills id start from one
#                                  rather than starting after the random number assigned to the fixtures.

# Omitted: group_leader_ledger_id, random: cheque number

# __TODO__ maybe: calculate the bills count dynamically.. making the test work with different test files?
#          where does the 'fycode' 7273 in bill id come from? Extract it dynamically?
require 'test_helper'
require "#{Rails.root}/app/globalhelpers/custom_date_module"

class BasicAppFlowTest < ActionDispatch::IntegrationTest
  include CustomDateModule
  def setup
    # To prevent isin company Nil Error in bills#show
    Rake::Task["fetch_companies"].invoke
    # Rake::Task["update_isin_prices"].invoke

    # fix the tenants issue
    host! 'trishakti.lvh.me'
    # Secure browsing!
    https!
    # login as existing user
    lalchan = users(:user)
    post_via_redirect new_user_session_path, 'user[email]' => lalchan.email, 'user[password]' => 'password'
    assert_equal root_path, path
    assert_equal 'Signed in successfully.', flash[:notice]

    # DO calculate these from the test files END
    @purchase_bills_expected_count = 51
    @sales_bills_expected_count = 45

    # where does this come from? (fy-code?)
    @bill_number_first_part = 7273

    @number_of_ledger_options_expected = 3 + 1 + 1
    # ledgers in fixtures + bank accounts w/ default for payment + bank accounts w/ default for reciept

    @additional_bank_id = Bank.first.id
    @cash_ledger_id = ledgers(:one).id

    # assume default pagination
    @items_in_first_pagination = 20

    @date_today = ad_to_bs(Date.today).to_s
  end

  test "the basic flow" do

    ############################################################### SECTION ONE ############################################################################

    # --- 1. Add Bank ---
    assert_difference 'Bank.count', 1 do
      post banks_path, bank: { address: 'utopia', bank_code: 'TBH', contact_no: '999999999', name: 'The Bank' }
    end
    new_bank = assigns(:bank)
    assert_redirected_to bank_path(new_bank)

    # --- 1.1 Add Bank Account- of created bank & existing bank ---
    existing_bank = banks(:one)
    assert_difference 'BankAccount.count', 2 do
      post bank_accounts_path, bank_account: {bank_id: new_bank.id, account_number: 619, "default_for_receipt"=>"1", "default_for_payment"=>"0",
                                   "ledger_attributes" => { opening_blnc: 500, opening_blnc_type: 0} }
      @bank_account_receipt = assigns(:bank_account)
      post bank_accounts_path, bank_account: {bank_id: existing_bank.id, account_number: 916, "default_for_receipt"=>"0", "default_for_payment"=>"1",
                                   "ledger_attributes" => { opening_blnc: 0, opening_blnc_type: 0} }
      @bank_account_payment = assigns(:bank_account)
    end
    assert_redirected_to bank_account_path(@bank_account_payment)

    ############################################################### SECTION TWO ############################################################################

    # --- 2. Add Cheque Entries ---
    assert_difference 'ChequeEntry.count', 20 do
      post cheque_entries_path, { bank_account_id: @bank_account_receipt.id, start_cheque_number: 1, end_cheque_number: 10 }
      post cheque_entries_path, { bank_account_id: @bank_account_payment.id, start_cheque_number: 11, end_cheque_number: 20 }
    end
    assert_redirected_to cheque_entries_path

    ############################################################### SECTION THREE ##########################################################################

    # --- 3. Upload Floorsheet of date X ---
    file = fixture_file_upload(Rails.root.join('test/fixtures/files/May10/BrokerwiseFloorSheetReport 10 May.xls'), 'text/xls')
    post import_files_floorsheets_path, file: file
    get files_floorsheets_path
    assert_not assigns(:file_list).empty?

    ############################################################### SECTION FOUR ###########################################################################

    # --- 4. Upload CM05 of date X ---
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

    # --- 4.1 Process Settlement ---
    get generate_bills_path(sales_settlement_id)
    assert_response :success
    assert_select 'h3', text: 'Bills generated Successfully'

    purchase_bills = Bill.find_by_bill_type('purchase')
    sales_bills =    Bill.find_by_bill_type('sales')
    # verify bills count
    assert_equal purchase_bills.count, @purchase_bills_expected_count
    assert_equal sales_bills.count,    @sales_bills_expected_count
    # purchase_bills_starting_id = Bill.first.id
    # sales_bills_starting_id = purchase_bills_starting_id + @purchase_bills_expected_count
    purchase_bills_starting_id = purchase_bills.first.id
    sales_bills_starting_id    = sales_bills.first.id

    ############################################################### SECTION FIVE ###########################################################################

    # --- 5. Go to bill list #sales
    get sales_bills_path
    # select method 2
    assert_match "Displaying bills <b>1&nbsp;-&nbsp;#{@items_in_first_pagination}</b> of <b>#{@sales_bills_expected_count}</b> in total", response.body

    # new_voucher_path_regex = /\/vouchers\/new\?bill_id=[0-9]{1,2}&amp;voucher_type=1/
    # bill_path_regex = /\/bills\/[0-9]{1,2}/
    # ! UNABLE TO WORKOUT REGEX !

    # check links
    # assert_select 'a[href^="/vouchers/new?bill_id="][href$="&voucher_type=1"]', {count:20, text: 'Process Bill'}
    sales_bills_ending_count_in_page = sales_bills_starting_id + @items_in_first_pagination - 1
    sales_bills_starting_id.upto(sales_bills_ending_count_in_page) do |bill_id|
      assert_select 'a[href=?]', new_voucher_full_path(bill_id, 1), text: 'Process Bill'
      assert_select 'a[href=?]', bill_path(bill_id),                text: 'View'
    end

    # Payment voucher
    # get new_voucher_path(bill_id: sales_bills_starting_id, voucher_type: 1)
    # --- 5.1 Process sales bills ---
    get new_voucher_full_path(sales_bills_starting_id, 1)
    # --- 5.1 - New payment voucher should be shown ---
    assert_select 'h2.section-title', text: 'New Payment Voucher'
    date_default_value = css_select("form.simple_form.new_voucher input[name='voucher[date_bs]']")[0]['value']
    # date_default_value = form_objects[0]['value']
    assert_equal @date_today, date_default_value
    # assert_contains ad_to_bs(Date.today).to_s, form_text
    # assert_select "input[type=text][name='voucher[date_bs]']", text: ad_to_bs(Date.today).to_s
    assert_select "input[name='voucher[desc]']", value: "Settled for Bill No: #{@bill_number_first_part}-#{sales_bills_starting_id}"

    assert_select '.voucher select#voucher_particulars_attributes_0_ledger_id' do
      assert_select 'option', @number_of_ledger_options_expected
      # --- 5.1 - Default credit ledger should default to corresponding bank for sales ---
      assert_select 'option[selected=selected]', {text:"Bank:#{@bank_account_payment.bank_name}(#{@bank_account_payment.account_number})",
                                                  value: @bank_account_payment.id.to_s}
    end
    # --- 5.1 - On create ---

    # little bit scraping - payment voucher
    first_particular_ledger_id, second_particular_ledger_id = [], []
    first_particular_ledger_id[0] = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    second_particular_ledger_id[0] = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    payment_amount = css_select('input#voucher_particulars_attributes_0_amount')[0]['value']

    # WHY IS THIS FIELD NOT PRESENT?
    # group_leader_ledger_id = css_select('input[name=group_leader_ledger_id]')[0]['value']
    # => 11(frontend): how?

    # Cannot check the default cheque number, being an ajax call;
    # default_cheque_number = css_select("input#voucher_particulars_attributes_0_cheque_number")[0]['value']
    cheque_num = '8374'

    post vouchers_path,
      {"voucher_type"=>"1",
       # "client_account_id"=>"",
       "bill_id"      =>"#{sales_bills_starting_id}",
       "clear_ledger" =>"false",
       "voucher"      =>
         {"date_bs"               => @date_today,
         "particulars_attributes" =>
           {"0"=>
             # {"ledger_id"         =>"#{@bank_account_payment.id}",
             {"ledger_id"         => first_particular_ledger_id[0],
             "amount"             => payment_amount,
             "transaction_type"   =>"cr",
             "cheque_number"      => cheque_num,
             "additional_bank_id" => @additional_bank_id},
           "3"=>
             {"ledger_id"         => second_particular_ledger_id[0],
             "amount"             => payment_amount,
             "transaction_type"   =>"dr",
             # "cheque_number"      =>"",
             "additional_bank_id" => @additional_bank_id}
           },
         "desc"                    =>"Settled for Bill No: #{@bill_number_first_part}-#{sales_bills_starting_id}"
         },
       "voucher_settlement_type" =>"default",
       # "group_leader_ledger_id"  =>"#{group_leader_ledger_id}",
       # "vendor_account_id"       =>"",
       # "commit"                  =>"submit"
      }
    voucher = assigns(:voucher)
    follow_redirect!
    assert_equal voucher_path(voucher), path
    assert_equal 'Voucher was successfully created.', flash[:notice]
    # --- 5.1 - On create - incase of payment by bank, payment voucher is created
    assert_select 'h3', 'Payment voucher Bank'
    # approve
    post finalize_payment_vouchers_path, {from_path: vouchers_path, id: "#{voucher.id}", approve: "approve"}

    assert_equal 'Payment Voucher was successfully approved', flash[:notice]
    assert_redirected_to vouchers_path

    # --- 5.1 - On create -incase of payment by cash, normal voucher is created
    get new_voucher_full_path(sales_bills_starting_id+1, 1)

    # little bit scraping again- payment voucher
    first_particular_ledger_id[1] = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    second_particular_ledger_id[1] = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    payment_amount = css_select('input#voucher_particulars_attributes_0_amount')[0]['value']
    # group_leader_ledger_id = css_select('input[name=group_leader_ledger_id]')[0]['value']
    post_via_redirect vouchers_path,
      {"voucher_type"=>"1",
       "bill_id"      =>"#{sales_bills_starting_id+1}",
       "clear_ledger" =>"false",
       "voucher"      =>
         {"date_bs"               => @date_today,
         "particulars_attributes" =>
           {"0"=>
             {"ledger_id"         => first_particular_ledger_id[1],
             "amount"             => payment_amount,
             "transaction_type"   =>"cr",
             "additional_bank_id" => @additional_bank_id},
           "3"=>
             {"ledger_id"         => second_particular_ledger_id[1],
             "amount"             => payment_amount,
             "transaction_type"   =>"dr",
             "additional_bank_id" => @additional_bank_id}
           },
         "desc"                    =>"Settled for Bill No: #{@bill_number_first_part}-#{sales_bills_starting_id+1}"
         },
       "voucher_settlement_type" =>"default",
       # "group_leader_ledger_id"  =>"#{group_leader_ledger_id}",
      }
    # --- 5.1 - On create -incase of payment by cash, normal voucher is created
    assert_select 'h4 u', 'PAYMENT'

    # --- 5. Go to bill list #purchase
    get purchase_bills_path
    assert_match "Displaying bills <b>1&nbsp;-&nbsp;#{@items_in_first_pagination}</b> of <b>#{@purchase_bills_expected_count}</b> in total", response.body
    # check links
    purchase_bills_ending_count_in_page = purchase_bills_starting_id + @items_in_first_pagination - 1
    purchase_bills_starting_id.upto(purchase_bills_ending_count_in_page) do |bill_id|
      assert_select 'a[href=?]', new_voucher_full_path(bill_id, 2), text: 'Process Bill'
      assert_select 'a[href=?]', bill_path(bill_id),        text: 'View'
      # first_particular_ledger_id.Bank ..
    end
    # --- 5.2 Process purchase bills ---
    get new_voucher_full_path(purchase_bills_starting_id, 2)
    # --- 5.2 - Receipt voucher should be shown with narration and amount ---
    assert_select 'h2.section-title', text: 'New Receipt Voucher'
    date_default_value = css_select("form.simple_form.new_voucher input[name='voucher[date_bs]']")[0]['value']
    assert_equal @date_today, date_default_value
    assert_select "input[name='voucher[desc]']", value: "Settled for Bill No: #{@bill_number_first_part}-#{purchase_bills_starting_id}"

    assert_select '.voucher select#voucher_particulars_attributes_0_ledger_id' do
      assert_select 'option', @number_of_ledger_options_expected
      # --- 5.2 - Default debit ledger should default to corresponding bank for sales ---
      assert_select 'option[selected=selected]', {text:"Bank:#{@bank_account_receipt.bank_name}(#{@bank_account_receipt.account_number})",
                                                  value: @bank_account_receipt.id.to_s}
    end

    # little bit scraping -receipt voucher
    first_particular_ledger_id[2] = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    second_particular_ledger_id[2] = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    payment_amount = css_select('input#voucher_particulars_attributes_0_amount')[0]['value']

    cheque_num = '3750'

    post vouchers_path,
      {"voucher_type"=>"2",
       "bill_id"      =>"#{purchase_bills_starting_id}",
       "clear_ledger" =>"false",
       "voucher"      =>
         {"date_bs"               => @date_today,
         "particulars_attributes" =>
           {"0"=>
             {"ledger_id"         => first_particular_ledger_id[2],
             "amount"             => payment_amount,
             "transaction_type"   =>"dr",
             "cheque_number"      => cheque_num,
             "additional_bank_id" => @additional_bank_id},
           "3"=>
             {"ledger_id"         => second_particular_ledger_id[2],
             "amount"             => payment_amount,
             "transaction_type"   =>"cr",
             # "cheque_number"      =>"",
             "additional_bank_id" => @additional_bank_id}
           },
         "desc"                    =>"Settled for Bill No: #{@bill_number_first_part}-#{purchase_bills_starting_id}"
         },
       "voucher_settlement_type" =>"default",
      }
    voucher = assigns(:voucher)
    settlement_ids = voucher.settlements.pluck(:id)
    follow_redirect!
    # %5B%5D == []
    assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    # --- 5.2 - On create - receipt should be created with relevant information ---
    assert_select 'h4 u', 'RECEIPT'
    assert_match payment_amount, response.body
    assert_match Bank.find(@additional_bank_id).name, response.body

    # Verify no process link in bill list
    get sales_bills_path
    assert_select 'a[href=?]', new_voucher_full_path(sales_bills_starting_id, 1),   {count:0, text: 'Process Bill'}
    assert_select 'a[href=?]', new_voucher_full_path(sales_bills_starting_id+1, 1), {count:0, text: 'Process Bill'}
    # --- 5.3 Verify in Ledgers for ledgers affected in step 5.1 & 5.2 ---
    ledger_index_to_particulars_count = [3, 4, 11]
    second_particular_ledger_id.each do |ledger_id|
      get ledger_path(ledger_id)
      assert_response :success

      particulars_num = ledger_index_to_particulars_count[second_particular_ledger_id.index(ledger_id)]
      assert_match "Displaying <b>all #{particulars_num}</b> particulars", response.body

      # test links!
      link_objects = css_select '.box-body.ledger.ledger-single a[data-remote=true]'
      link_objects.each do |link_obj|
        # Add more extended tests here?
        link = link_obj['href']
        get link
        assert_response :success
        unless link.include? 'cheque_entries'
          header_text_initial = case link
          when /vouchers/
            'Voucher'
          when /bills/
            'Bill'
          when /settlements/
            'Settlement'
          end
          header_text = "#{header_text_initial} Details"
          # Not h3.modal-title, coz we're checking direct link, not ajax
          assert_select 'h2.section-title', header_text
        else
          # No cheque details header in direct link!
          assert_match 'Pay against this cheque to', response.body
        end
      end
    end

    ############################################################### SECTION SIX ############################################################################

    # --- 6. Client Ledgers ---
    #
    get client_ledgers_path
    assert_response :success
    client_ledgers_count = Ledger.find_all_client_ledgers.count
    assert_match "Displaying ledgers <b>1&nbsp;-&nbsp;#{@items_in_first_pagination}</b> of <b>#{client_ledgers_count}</b> in total", response.body

    # cut the crap!
    # --- 6. - Process sales bills
    # --- 6. - Process purchase bills
    # sales_bill = Ledger.find_all_client_ledgers.where("closing_blnc<0").first
    # get client_bills_path(sales_bill.client_account_id)
    # purchase_bill = Ledger.find_all_client_ledgers.where("closing_blnc>0").first
    # get client_bills_path(purchase_bill.client_account_id)
    # bill_id = css_select("input[name='bill_ids[]']")[0]['value']

    # --- 6.1 Process ledger & verify ---
    ledger = Ledger.find_all_client_ledgers.first
    client_account_id = ledger.client_account_id
    get ledger_path(ledger.id)
    assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger'}
    assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills'}
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
    assert_select 'h2.section-title', text: 'New Payment Voucher'

    # scraping!
    first_particular_ledger_id[3] = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    second_particular_ledger_id[3] = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    payment_amount = css_select('input#voucher_particulars_attributes_0_amount')[0]['value']

    cheque_num = '5234'

    bill_numbers = "#{@bill_number_first_part}-" + bill_ids.join(", #{@bill_number_first_part}-")

    post vouchers_path,
      {"voucher_type"=>"1",
       "client_account_id" =>"#{client_account_id}",
       # "bill_id"         =>"",
       "clear_ledger"      =>"false",
       "bill_ids"          =>bill_ids,
       "voucher"           =>
         {"date_bs"               => @date_today,
         "particulars_attributes" =>
           {"0"=>
             {"ledger_id"         => first_particular_ledger_id[3],
             "amount"             => payment_amount,
             "transaction_type"   =>"cr",
             "cheque_number"      => cheque_num,
             "additional_bank_id" => @additional_bank_id},
           "3"=>
             {"ledger_id"         => second_particular_ledger_id[3],
             "amount"             => payment_amount,
             "transaction_type"   =>"dr",
             # "cheque_number"      =>"",
             "additional_bank_id" => @additional_bank_id}
           },
         "desc"                    =>"Settled for Bill No: #{bill_numbers}"
         },
       "voucher_settlement_type" =>"default",
      }
    voucher = assigns(:voucher)
    follow_redirect!
    case voucher.voucher_type
    when 'payment'
      assert_equal voucher_path(voucher), path
      assert_select 'h3', 'Payment voucher Bank'
      post finalize_payment_vouchers_path, {from_path: vouchers_path, id: "#{voucher.id}", approve: "approve"}
      assert_equal 'Payment Voucher was successfully approved', flash[:notice]
    when 'receipt'
      settlement_ids = voucher.settlements.pluck(:id)
      assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
      assert_select 'h4 u', 'RECEIPT'
    end
    # rest of the select tests already done above
    # fetch the same ledger again
    get ledger_path(ledger.id)
    assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger',           count: 0}
    assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills', count: 0}

    # --- 6.2 Clear ledger & verify ---
    ledger = Ledger.find_all_client_ledgers.second
    client_account_id = ledger.client_account_id
    get ledger_path(ledger.id)
    assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger'}
    assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills'}

    get new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id)
    assert_select 'h2.section-title', "New #{voucher.voucher_type.capitalize} Voucher"

    # scraping!
    first_particular_ledger_id[3] = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    second_particular_ledger_id[3] = css_select('select#voucher_particulars_attributes_3_ledger_id option[selected=selected]')[0]['value']
    payment_amount = css_select('input#voucher_particulars_attributes_0_amount')[0]['value']

    cheque_num = '5344'
    voucher_type_code, transaction_type_first, transaction_type_second = case voucher.voucher_type
    when 'payment' then [1, 'cr', 'dr']
    when 'receipt' then [2, 'dr', 'cr']
    end
    # transaction_type_second = transaction_type_first == 'cr' ? 'dr':'cr'

    post vouchers_path, {
       "voucher_type"      => voucher_type_code,
       "client_account_id" =>"#{client_account_id}",
       # "bill_id"         =>"",
       "clear_ledger"      =>"true",
       "voucher"           =>
         {"date_bs"               => @date_today,
         "particulars_attributes" =>
           {"0"=>
             {"ledger_id"         => first_particular_ledger_id[3],
             "amount"             => payment_amount,
             "transaction_type"   => transaction_type_first,
             "cheque_number"      => cheque_num,
             "additional_bank_id" => @additional_bank_id},
           "3"=>
             {"ledger_id"         => second_particular_ledger_id[3],
             "amount"             => payment_amount,
             "transaction_type"   => transaction_type_second,
             # "cheque_number"      =>"",
             "additional_bank_id" => @additional_bank_id}
           },
         "desc"                    =>"Settled with ledger balance clearance"
        },
       "payment_mode"=>"default",
       "voucher_settlement_type"=>"default",
       "vendor_account_id"=>""
       # "group_leader_ledger_id"=>"14",
      }
    voucher = assigns(:voucher)
    follow_redirect!
    case voucher.voucher_type
    when 'payment'
      assert_equal voucher_path(voucher), path
      assert_select 'h3', 'Payment voucher Bank'
      post finalize_payment_vouchers_path, {from_path: vouchers_path, id: "#{voucher.id}", approve: "approve"}
      assert_equal 'Payment Voucher was successfully approved', flash[:notice]
    when 'receipt'
      settlement_ids = voucher.settlements.pluck(:id)
      assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
      assert_select 'h4 u', 'RECEIPT'
    end
    # rest of the select tests already done above
    # fetch the same ledger again
    get ledger_path(ledger.id)
    assert_select 'a[href=?]', new_voucher_path(clear_ledger: 'true', client_account_id: client_account_id), {text: 'Clear Ledger',           count: 0}
    assert_select 'a[href=?]', client_bills_path(client_account_id),                                         {text: 'Process Selected Bills', count: 0}


    ############################################################### SECTION SEVEN ##########################################################################

    # --- 7. Voucher creation --- Create all types of vouchers ---
    # --- 7.1 Journal with out Bank ---
    get new_voucher_path
    assert_response :success
    assert_select 'h2.section-title', text:'New Journal Voucher'
    assert_select 'form.simple_form.new_voucher input#voucher_date_bs', value: @date_today
    assert_select 'select#voucher_particulars_attributes_0_ledger_id option[selected=selected]', count: 0 # no pre-"selected" option
    ledger_options = css_select 'select#voucher_particulars_attributes_0_ledger_id option'
    assert_equal 'Cash', ledger_options[0].text  # first option should be cash

    # Select some random person to credit
    credited_ledger_id = ledger_options[4]['value']
    credited_ledger_name = ledger_options[4].text
    payment_amount = "500.00"
    post vouchers_path, {
       "voucher_type"      =>"0",
       "clear_ledger"      =>"false",
       "voucher"=>{
         "date_bs"                =>@date_today,
         "particulars_attributes" =>{
           "0"=>{
             "ledger_id"          =>@cash_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"dr",
             "additional_bank_id" =>@additional_bank_id
             },
           # "1464762265417"=>{
           "3"=>{
             "ledger_id"          =>credited_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"cr",
             "additional_bank_id" =>@additional_bank_id
             }
          }
        },
       "payment_mode"=>"default",
    }

    voucher = assigns(:voucher)
    follow_redirect!
    assert_equal voucher_path(voucher), path
    assert_equal 'Voucher was successfully created.', flash[:notice]
    assert_select 'h2.section-title', 'Voucher Details'

    assert_match credited_ledger_name, response.body # credited party
    assert_match 'Cash', response.body # debited party
    assert_match payment_amount, response.body # amount
    assert_match "Voucher Date: #{@date_today}", response.body # voucher date
    assert_match "#{@bill_number_first_part}-#{voucher.voucher_number}", response.body # voucher number

    # --- 7.2 Journal with Bank Account credit ---
    get new_payment_voucher_path
    assert_response :success
    assert_select 'h2.section-title', text:'New Payment Voucher'
    assert_select 'form.simple_form.new_voucher input#voucher_date_bs', value: @date_today
    assert_select 'select#voucher_particulars_attributes_0_ledger_id option[selected=selected]', text: "Bank:#{@bank_account_payment.bank.name}(#{@bank_account_payment.account_number})"
    # first transaction type credit & disabled
    assert_select 'select[disabled=disabled]#voucher_particulars_attributes_0_transaction_type' do
      assert_select 'option[selected=selected]', {text: 'cr'}
    end
    # second transaction type debit & disabled
    assert_select 'select[disabled=disabled]#voucher_particulars_attributes_3_transaction_type' do
      assert_select 'option[selected=selected]', {text: 'dr'}
    end
    credited_bank_account_ledger_id = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    ledger_options = css_select 'select#voucher_particulars_attributes_3_ledger_id option'

    # Select a person to credit
    credited_ledger_id = ledger_options[10]['value']
    credited_ledger_name = ledger_options[10].text
    payment_amount = "500.00"
    cheque_num = "948" #random
    post vouchers_path, {
       "voucher_type"      =>"1",
       "clear_ledger"      =>"false",
       "voucher"=>{
         "date_bs"                =>@date_today,
         "particulars_attributes" =>{
           "0"=>{
             "ledger_id"          =>credited_bank_account_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"cr",
             "cheque_number"      =>cheque_num,
             "additional_bank_id" =>@additional_bank_id
             },
           "3"=>{
             "ledger_id"          =>credited_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"dr",
             "additional_bank_id" =>@additional_bank_id
             }
          },
          "desc"=>''
        },
       "payment_mode"            =>"default",
       "voucher_settlement_type" =>"default",
       # "group_leader_ledger_id"  =>
    }

    voucher = assigns(:voucher)
    settlement_ids = voucher.settlements.pluck(:id)

    follow_redirect!
    assert_equal voucher_path(voucher), path
    assert_select 'h3', 'Payment voucher Bank'

    assert_match credited_ledger_name, response.body
    assert_match payment_amount, response.body
    assert_match cheque_num, response.body
    assert_match "Voucher Date: #{@date_today}", response.body

     # --- 7.3 Journal with Bank Account debit ---
    get new_receipt_voucher_path
    assert_response :success
    assert_select 'h2.section-title', text:'New Receipt Voucher'
    assert_select 'form.simple_form.new_voucher input#voucher_date_bs', value: @date_today
    assert_select 'select#voucher_particulars_attributes_0_ledger_id option[selected=selected]', text: "Bank:#{@bank_account_receipt.bank.name}(#{@bank_account_receipt.account_number})"
    # first transaction type debit & disabled
    assert_select 'select[disabled=disabled]#voucher_particulars_attributes_0_transaction_type' do
      assert_select 'option[selected=selected]', {text: 'dr'}
    end
    # second transaction type credit & disabled
    assert_select 'select[disabled=disabled]#voucher_particulars_attributes_3_transaction_type' do
      assert_select 'option[selected=selected]', {text: 'cr'}
    end
    debited_bank_account_ledger_id = css_select('select#voucher_particulars_attributes_0_ledger_id option[selected=selected]')[0]['value']
    ledger_options = css_select 'select#voucher_particulars_attributes_3_ledger_id option'
    # Select a person to credit
    credited_ledger_id = ledger_options[10]['value']
    credited_ledger_name = ledger_options[10].text
    payment_amount = "500.00"

    post vouchers_path, {
       "voucher_type"      =>"2",
       "clear_ledger"      =>"false",
       "voucher"=>{
         "date_bs"                =>@date_today,
         "particulars_attributes" =>{
           "0"=>{
             "ledger_id"          =>debited_bank_account_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"dr",
             "additional_bank_id" =>@additional_bank_id
             },
           "3"=>{
             "ledger_id"          =>credited_ledger_id,
             "amount"             =>payment_amount,
             "transaction_type"   =>"cr",
             "additional_bank_id" =>@additional_bank_id
             }
          }
        },
       "payment_mode"            =>"default",
       "voucher_settlement_type" =>"default",
       # "group_leader_ledger_id"  =>
    }
    voucher = assigns(:voucher)
    settlement_ids = voucher.settlements.pluck(:id)
    follow_redirect!
    assert_equal show_multiple_settlements_path('settlement_ids'=> settlement_ids), request.original_fullpath
    assert_select 'h4 u', 'RECEIPT'

    assert_match payment_amount, response.body
    assert_match credited_ledger_name, response.body
    assert_match "Date: #{@date_today}", response.body
    receipt_num = Settlement.find(settlement_ids[0]).id
    assert_match "Receipt No: #{receipt_num}", response.body

  end


  private
    # DO make the individual params/args instance variables if always the same END
    def generate_bills_path(sales_settlement_id)
      "#{generate_bills_sales_settlements_path}?id=#{sales_settlement_id}"
    end

    def sales_bills_path
      # "#{bills_path}?utf8=✓&search_by=bill_type&search_term=sales&commit=Search"
      "#{bills_path}?utf8=%E2%9C%93&search_by=bill_type&search_term=sales&commit=Search"
    end

    def purchase_bills_path
      "#{bills_path}?utf8=%E2%9C%93&search_by=bill_type&search_term=purchase&commit=Search"
    end

    def new_voucher_full_path(bill_id, voucher_type)
      "#{new_voucher_path}?bill_id=#{bill_id}&voucher_type=#{voucher_type}"
    end

    def ledger_full_path(ledger_id)
      "#{ledgers_path}?utf8=%E2%9C%93&search_by=ledger_name&search_term=#{ledger_id}&commit=Search"
    end

    def client_ledgers_path
      "#{ledgers_path}?show=all_client"
    end

    def new_receipt_voucher_path
      "#{new_voucher_path}?voucher_type=2"
    end

    def new_payment_voucher_path
      "#{new_voucher_path}?voucher_type=1"
    end

    def client_bills_path(client_acc_id)
      "#{bills_path}?search_by=client_id&search_term=#{client_acc_id}"
    end

end
