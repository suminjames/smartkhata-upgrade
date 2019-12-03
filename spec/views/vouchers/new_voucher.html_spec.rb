require 'rails_helper'
require 'fiscal_year_module'

RSpec.describe "voucher_request/new", type: :view do
  let(:branch_kat) { Branch.create(code: 'KTM', address: 'Kathmandu') }
  let(:branch_chi) { Branch.create(code: 'CHI', address: 'Chitwan') }
  let(:user) { create(:user) }

  before(:each) do
    @voucher_type = 1
    UserSession.user = user
    2.times { create(:ledger) }
    creator = create(:creator)
    bank_account = create(:bank_account, creator: creator, updater: creator)
    @client_account = create(:client_account, creator_id: creator.id, updater_id: creator.id)
    clear_ledger = false
    @selected_fy_code = '7576'
    @selected_branch_id = branch_kat.id
    Vouchers::Setup.new(voucher_type: @voucher_type,
                        client_account_id: @client_account.id,
                        # bill_id: @bill_id,
                        clear_ledger: clear_ledger,
                        bill_ids: @bill_ids).voucher_and_relevant(branch_kat.id, @selected_fy_code)
  end

  it "render voucher new page" do
    voucher = create(:voucher)
    render template: 'vouchers/_form', locals: { voucher: voucher, voucher_type: @voucher_type,
      client_account_id: @client_account.id, selected_branch_id: @selected_branch_id,
      bill_id: nil, clear_ledger: false, bill_ids: [], payment_mode: nil,
      is_payment_receipt: false, ledger_list_financial: nil, ledger_list_available: nil,
      default_ledger_id: nil,
      particular_fields: render(partial: 'vouchers/particular_fields', locals: {
        extra_info:{
          ledger_list_available: [],ledger_list_financial: [],
          voucher_type: @voucher_type, inverse: false, default_ledger_id: nil
        },
        sk_id: 2
      })

    }
  end
end
