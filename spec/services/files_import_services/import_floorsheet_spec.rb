require 'rails_helper'

RSpec.describe FilesImportServices::ImportFloorsheet do
  include_context 'session_setup'
  let!(:share_transaction){create(:share_transaction)}
  let!(:bill){create(:bill, bill_number: 1, fy_code: 7475)}
  let!(:client_account){create(:client_account, name: 'User One', branch_id: 2, nepse_code: 'SK1')}
  let!(:commission_info) {create(:master_setup_commission_info, start_date: "2016-07-24", end_date: "2021-12-31", start_date_bs: nil, end_date_bs: nil, nepse_commission_rate: 20.0)}

  describe 'get_bill_number' do
    it 'should return bill number' do
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(nil)
      expect(import_floorsheet.get_bill_number(7475)).to eq(2)
    end
  end

  describe 'process_record_for_full_upload' do
    it 'should return array' do
      hash_dp_count = {"SK1SHPCbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      settlement_date = '2016-12-06'
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-15.xls')
      array = [201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8]
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
      expect(import_floorsheet.process_record_for_full_upload(array, hash_dp, fy_code,hash_dp_count,'2016-12-06', commission_info)).to eq('')
    end
  end

end