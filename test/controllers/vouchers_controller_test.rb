require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user)
    @voucher_types = Voucher.voucher_types.keys
    @voucher = vouchers(:voucher_0)
    # fix tenants issue
    @request.host = 'trishakti.lvh.me'
    @assert_block_via_get = lambda { |action|
      get action, id: @voucher
      assert_response :success
      assert_template "vouchers/#{action}"
    }
    @assert_block_via_finalize_payment = lambda { |finalize_type|
      voucher = vouchers(:voucher_pending)
      assert voucher.pending?
      params = {id: voucher}
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
      voucher_code = Voucher.voucher_types[voucher_type]
      assert_difference 'Voucher.count', 1 do
        params =
          {"voucher_type"=> "#{voucher_code}",
           "voucher"      =>
             {"date_bs"               => '2072-01-02',
             "particulars_attributes" =>
               {"0"=>
                 {"ledger_id"         => ledgers(:two).id,
                 "amount"             => 5000,
                 "transaction_type"   => 'cr',
                 "cheque_number"      => '392',
                 "additional_bank_id" => Bank.first.id
                },
               "2"=>
                 {"ledger_id"         => ledgers(:five).id,
                 "amount"             => 5000,
                 "transaction_type"   => 'dr',
                 "additional_bank_id" => Bank.first.id
                }
              },
            },
            "vendor_account_id"       => vendor_accounts(:one).id,
            "voucher_settlement_type" => 'vendor'
          }
        post :create, params
      end
      assert_equal "Voucher was successfully created.", flash[:notice]
      assert_redirected_to voucher_path(assigns(:voucher))
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
    assert_difference 'Voucher.count', -1 do
      delete :destroy, id: @voucher
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
