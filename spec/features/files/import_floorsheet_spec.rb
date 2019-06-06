require 'rails_helper'

describe "Import Floorsheet" do
  include_context "feature_session_setup"

  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    before do
      login_as(@user, scope: :user)
      allow(Calendar).to receive(:t_plus_3_trading_days).and_return(Date.parse("2016-11-28"))
      setup_commission
    end

    it "should show form for upload", js: true do
      upload_file
      expect(page).to have_content("FLOORSHEET IMPORT CANCELLED! New client accounts found in the file! Please manually create the client accounts for the following in the system first, before re-uploading the floorsheet. If applicable, please make sure to assign the correct branch to the client account so that billing is tagged to the appropriate branch.")

      generate_clients
      bills_count = Bill.all.count
      vouchers_count = Voucher.all.count
      upload_file
      expect(page).to have_content("FloorSheet Uploaded Successfully")
      expect(Bill.count).to eq(bills_count + 3)
      expect(Voucher.count).to eq(vouchers_count + 15)
      visit("/vouchers/#{Voucher.unscoped.last.id}")
      visit("/bills/#{Bill.unscoped.last.id}")
    end

    def upload_file
      visit new_files_floorsheet_path
      attach_file "file", Rails.root + "test/fixtures/files/floorsheets/v2/floor_sheet_broker_48_2073-08-10.xls"
      click_on "Import"
    end

    def generate_clients
      new_client_accounts = [
        { client_name: "USER TWO COMPANY LTD.", client_nepse_code: 'SK2' },
        { client_name: "USER FOUR", client_nepse_code: 'SK4' },
        { client_name: "USER FIVE", client_nepse_code: 'SK5' },
      ]

      new_client_accounts.each do |new_client_account|
        ClientAccount.create(
          {
            :name => new_client_account[:client_name],
            :nepse_code => new_client_account[:client_nepse_code],
            :branch_id =>  @branch.id,
            :skip_validation_for_system => true
          }
        )
      end
    end

    def setup_commission
      commission_rate = MasterSetup::CommissionInfo.new(start_date: Date.parse('2016-07-24'), end_date: '2021-12-31', nepse_commission_rate: 20)

      commission_details = MasterSetup::CommissionDetail
                             .create([
                                       {start_amount: 0, limit_amount: 4166.67, commission_amount: 25},
                                       {start_amount: 4166.67, limit_amount: 50000.0, commission_rate: 0.6},
                                       {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.55},
                                       {start_amount: 500000.0, limit_amount: 2000000.0, commission_rate: 0.5},
                                       {start_amount: 2000000.0, limit_amount: 	10000000.0, commission_rate: 0.45},
                                       {start_amount: 	10000000.0, limit_amount: 99999999999.0, commission_rate: 0.4},
                                     ])

      commission_rate.commission_details << commission_details
      commission_rate.save!
    end
  end
end
