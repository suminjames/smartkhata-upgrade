require 'test_helper'
class Vouchers::SetupTest < ActiveSupport::TestCase
  attr_accessor :client_account, :ledger, :purchase_bill, :sales_bill

  def setup
    @client_account = create(:client_account)
    @ledger = client_account.ledger
    @purchase_bill = create(:purchase_bill, client_account: client_account, net_amount: 3000)
    @sales_bill = create(:sales_bill, client_account: client_account, net_amount: 2000)

    @assert_smartkhata_error = lambda { |voucher_base, client_account_id, bill_ids|
      assert_raise SmartKhataError do
        voucher_base.instance_eval{ set_bill_client(client_account_id, bill_ids) }
      end
    }
  end
end