require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @voucher_types = Voucher.voucher_types.keys
    @voucher = vouchers(:voucher_0)
    @approved_cheque = cheque_entries(:two)
    @receipt_code =  Voucher.voucher_types['receipt']
    @payment_code =  Voucher.voucher_types['payment']
    @additional_bank_id = Bank.first.id

    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    # set a fixed fy_code to test with relevant date
    set_fy_code_and_branch_from @voucher

    @assert_block_via_get = lambda { |action|
      get action, id: @voucher
      assert_response :success
      assert_template "vouchers/#{action}"
    }
    @assert_block_via_finalize_payment = lambda { |finalize_type|
      voucher = vouchers(:voucher_pending)
      assert voucher.pending?
      params = {id: voucher, from_path: vouchers_path}
      msg_suffix = case finalize_type
      when 'approve'
        params[:approve] = 'true'
        'approved'
      else
        params[:reject] = 'true'
        'rejected'
      end
      post :finalize_payment, params
      assert_equal "Payment Voucher was successfully #{msg_suffix}", flash[:notice]
      voucher.reload
      assert_not voucher.pending?
    }
    @post_vouchers_path = proc { |voucher_code, cheque_number, amt, particulars_to_ignore|
      amt ||= 5000
      params =
       {"voucher_type"=> "#{voucher_code}",
       "voucher"      =>
         {"date_bs"               => '2072-05-02',
         "particulars_attributes" => {},
         },
        "vendor_account_id"       => vendor_accounts(:one).id,
        "voucher_settlement_type" => 'vendor'
       }
       unless particulars_to_ignore == 2
        params["voucher"]["particulars_attributes"]["0"] =
              {"ledger_id"         => ledgers(:two).id,
               "amount"             => amt,
               "transaction_type"   => 'cr',
               "cheque_number"      => cheque_number,
               "additional_bank_id" => @additional_bank_id
              }
        unless particulars_to_ignore == 1
          params["voucher"]["particulars_attributes"]["2"] =
                {"ledger_id"         => ledgers(:five).id,
                 "amount"             => amt,
                 "transaction_type"   => 'dr',
                 "additional_bank_id" => @additional_bank_id
                }
        end
       end
      post :create, params
    }
    @assert_block_via_invalid_post = proc { |cheque_number, amt, error_msg, particulars_to_ignore|
      assert_no_difference 'Voucher.count' do
        @post_vouchers_path.call(@receipt_code, cheque_number, amt, particulars_to_ignore)
      end
      assert_equal error_msg, flash[:error]
      assert_response :success
    }
  end

  test "should get new for all types of vouchers" do
    @voucher_types.each do |voucher_type|
      voucher_code = Voucher.voucher_types[voucher_type]
      get :new, voucher_type: voucher_code
      assert_response :success
      assert_select 'h2.section-title', "New #{voucher_type.capitalize} Voucher"
    end
  end

  test "should create all types of vouchers" do
    @voucher_types.each do |voucher_type|
      voucher_type_code = Voucher.voucher_types[voucher_type]
      assert_difference 'Voucher.count', 1 do
        @post_vouchers_path.call(voucher_type_code, '392')
      end
      assert_equal "Voucher was successfully created.", flash[:notice]
      assert_redirected_to voucher_path(assigns(:voucher))
    end
  end

  test "should get pending vouchers" do
    get :pending_vouchers
    pending_vouchers = Voucher.pending.order("id ASC").decorate
    assert_equal assigns(:vouchers), pending_vouchers
    assert_template "vouchers/index"
  end

  # Testing set_bill_client method: Returns an array of relevant info
  # Note: Apparently does not 'set' anything!
  test "set bill client" do
    bill_1 = bills(:one)
    client_account_1 = bill_1.client_account
    bill_2 = bills(:two)
    client_account_2 = bill_2.client_account

    set_1 = @controller.set_bill_client(client_account_1.id, bill_1.id, @receipt_code)
    set_2 = @controller.set_bill_client(client_account_2.id, bill_2.id, @payment_code)

    bills_1 = client_account_1.bills.requiring_receive
    amount_1 = bills_1.sum(:balance_to_pay).abs
    bill_1 = bill_2 = nil # bacause of controller logic
    assert_equal [client_account_1, bill_1, bills_1, amount_1], set_1

    bills_2 = client_account_2.bills.requiring_payment
    amount_2 = bills_2.sum(:balance_to_pay).abs.round(2)
    assert_equal [client_account_2, bill_2, bills_2, amount_2], set_2
  end

  # Invalid input tests
  # Edit after merge to pass THIS test !
  test "should not create invalid voucher: receipt voucher with a cheque_number that has already been assigned" do
    get :new # to set UserSession
    @approved_cheque.update_attribute(:additional_bank_id, @additional_bank_id)

    # @assert_block_via_invalid_post.call(@approved_cheque.cheque_number, '5000', 'Cheque Number is already taken')
    amt = 5000
    assert_no_difference 'Voucher.count' do
      params = {
            "voucher_type" =>"2",
            # "client_account_id"=>"",
            # "bill_id"=>"",
            # "clear_ledger"=>"false",
            "voucher" => {
              "date_bs"                => "2072-05-02",
              "particulars_attributes" => {
                "0"=> {
                  "ledger_id"          => ledgers(:two).id,
                  "amount"             => amt,
                  "transaction_type"   => "dr",
                  "cheque_number"      => @approved_cheque.cheque_number,
                  "additional_bank_id" => @additional_bank_id,
                  # "id"               => ""
                },
                "3"=> {
                  "ledger_id"          => ledgers(:five).id,
                  "amount"             => amt,
                  "transaction_type"   => "cr",
                  # "cheque_number"    => "",
                  "additional_bank_id" => @additional_bank_id
                }
              },
              # "desc"=>""
            },
            "payment_mode"=>"default",
            "voucher_settlement_type"=>"default",
      }
      post :create, params
    end
    # assert_equal 'Cheque Number is already taken', flash[:error]
    assert_equal 'Cheque Number is invalid', flash[:error]
    assert_response :success
  end

  test "should not create invalid voucher: negative amount or cheque number" do
    @assert_block_via_invalid_post.call('-245', '5000', 'Cheque Number is invalid')
    @assert_block_via_invalid_post.call('245', '-5000', 'Amount can not be negative or zero.')
  end

  test "should not create invalid voucher: zero or one particular" do
    [1, 2].each do |particulars_to_ignore|
      @assert_block_via_invalid_post.call('245', '5000', 'Please include atleast 1 particular', particulars_to_ignore)
    end
  end

  test "should show voucher" do
    @assert_block_via_get.call(:show)
  end

  # Updating voucher should not be allowed !?
  test "should update voucher" do
    assert_not_equal '2073-03-03', @voucher.date_bs
    patch :update, id: @voucher, voucher: { date_bs: '2073-03-03'}
    assert_redirected_to voucher_path(assigns(:voucher))
    assert_equal "Voucher was successfully updated.", flash[:notice]
    @voucher.reload
    assert_equal '2073-03-03', @voucher.date_bs
  end

  test "should destroy voucher" do
    deletable_voucher = vouchers(:voucher_2)
    assert_difference 'Voucher.count', -1 do
      delete :destroy, id: deletable_voucher
    end
    assert_equal "Voucher was successfully destroyed.", flash[:notice]
    assert_redirected_to vouchers_path
  end

  test "should finalize payment: approve" do
    @assert_block_via_finalize_payment.call('approve')
  end

  test "should finalize payment: reject" do
    @assert_block_via_finalize_payment.call('reject')
  end

  test "should throw relevant error when finalizing payment of completed vouchers" do
    voucher = vouchers(:voucher_0)
    assert voucher.complete?
    post :finalize_payment, id: voucher, from_path: vouchers_path
    assert_equal "Voucher is already processed.", flash[:alert]
    assert_redirected_to vouchers_path
  end
end
