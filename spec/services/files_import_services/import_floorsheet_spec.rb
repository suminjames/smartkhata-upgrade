require 'rails_helper'

RSpec.describe FilesImportServices::ImportFloorsheet do
  include_context 'session_setup'
  include CommissionModule
  include ShareInventoryModule

  # let!(:share_transaction){create(:share_transaction)}
  let!(:isin_info) {create(:isin_info, isin: 'SHPC')}
   # let!(:voucher) {create(:voucher, date: '2016-12-01', date_bs: '2073-08-16', desc: "Shares purchased (64*SHPC@800.0) for USER ONE")}
  let!(:voucher) {create(:voucher, fy_code: 7374, date: "2016-12-01", date_bs: "2073-08-16", desc: 'test')}
  let!(:client_account){create(:client_account, name: 'User One', branch_id: 2, nepse_code: 'SK1')}
  let!(:commission_info) {create(:master_setup_commission_info, start_date: "2016-07-24", end_date: "2021-12-31", start_date_bs: nil, end_date_bs: nil, broker_commission_rate: 80.0, nepse_commission_rate: 20.0)}
  # let!(:share_inventory) {create(:share_inventory, client_account_id: client_account.id, isin_info_id: isin_info.id)}
  # let!(:share_transaction) {create(:share_transaction, contract_no: 201612014121143, buyer: 99, seller: 42, raw_quantity: 64, quantity: 64, share_rate: 800.0, share_amount: 51200.0, sebo: 7.68, commission_rate: 1.5, commission_amount: 768.0, dp_fee: 25.0, cgt: 0, )}

  # let!(:client_ledger) {create(:ledger, name: "User One", client_code: "SK1", group_id: Group.first.id, client_account_id: client_account.id)}
  let!(:purchase_commission_ledger) {create(:ledger, name: "Purchase Commission")}
  let!(:nepse_ledger) {create(:ledger, name: "Nepse Purchase")}
  let!(:tds_ledger) {create(:ledger, name: "TDS")}
  let!(:dp_ledger) {create(:ledger, name: "DP Fee/ Transfer")}

  let!(:particular_client_ledger) {create(:particular, transaction_type: 0, ledger_id: client_account.ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 52000.68, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let!(:particular_tds_ledger) {create(:particular, transaction_type: 0, ledger_id: tds_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 92.16, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let!(:particular_purchase_commission_ledger) {create(:particular, transaction_type: 1, ledger_id: purchase_commission_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 614.4, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let!(:particular_dp_ledger) {create(:particular, transaction_type: 1, ledger_id: dp_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 25.0, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let!(:particular_nepse_ledger) {create(:particular, transaction_type: 1, ledger_id: nepse_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 51453.44, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}

  describe 'get_bill_number' do
    it 'should return bill number' do
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(nil)
      expect(import_floorsheet.get_bill_number(7475)).to eq(1)
    end
  end

  describe 'process_record_for_full_upload' do
    # let(:commission) { Class.new { extend CommissionModule } }
    # let(:share_inventory) { Class.new { extend ShareInventoryModule } }
    # let(:application_helper) { Class.new { extend ApplicationHelper } }
    it 'should return array' do
      hash_dp_count = {"SK1SHPCbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      settlement_date = '2016-12-06'
      description = "Shares purchased (64*SHPC@800.0) for USER ONE"
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-15.xls')
      array = [201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8]
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
      import_floorsheet.instance_variable_set(:@bill_number, 1)
      import_floorsheet.instance_variable_set(:@date, '2016-12-01'.to_date)
      # allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-12-01'.to_date).and_return('2016-12-06')
      # allow_any_instance_of(FilesImportServices::ImportFloorsheet).to receive(:get_bill_number).with(7374).and_return(1)
      # import_floorsheet.process_full
      allow(import_floorsheet).to receive(:get_commission).with(51200.0, commission_info).and_return(768.0)
      allow(import_floorsheet).to receive(:get_commission_rate).with(51200.0, commission_info).and_return(1.5)
      allow(import_floorsheet).to receive(:broker_commission).with(768.0, commission_info).and_return(614.4)
      allow(import_floorsheet).to receive(:nepse_commission_amount).with(768.0, commission_info).and_return(153.6)
      allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 64, true).and_return(true)
      allow(Voucher).to receive(:create!).with(date: '2016-12-01'.to_date, date_bs: '2073-08-16').and_return(voucher)
      allow(import_floorsheet).to receive(:process_accounts).with(client_account.ledger, voucher, true, 52000.68, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_client_ledger)
      allow(import_floorsheet).to receive(:process_accounts).with(tds_ledger, voucher, true, 92.16, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_tds_ledger)
      allow(import_floorsheet).to receive(:process_accounts).with(purchase_commission_ledger, voucher, false, 614.4, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_purchase_commission_ledger)
      allow(import_floorsheet).to receive(:process_accounts).with(dp_ledger, voucher, false, 25.0, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_dp_ledger)
      allow(import_floorsheet).to receive(:process_accounts).with(nepse_ledger, voucher, false, 51453.44, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_nepse_ledger)
      expect(import_floorsheet.process_record_for_full_upload(array, hash_dp, fy_code,hash_dp_count,'2016-12-06'.to_date, commission_info)).to eq([201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8, 52000.68, 92.16, 768.0, 51453.44, 25.0, 1, true, '2016-12-01', 1, "7374-1", ShareTransaction.last])
    end
  end

end
# client_dr: 52000.68,tds: 92.16,commission:768.0,bank_deposit:51453.44,dp;25.0,bill_id:1,is_purchase:true,date:Thu, 01 Dec 2016,client_id:2,full_bill_number:"7374-1",