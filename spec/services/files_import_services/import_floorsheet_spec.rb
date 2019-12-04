require 'rails_helper'

RSpec.describe FilesImportServices::ImportFloorsheet do
  include_context 'session_setup'
  include CommissionModule
  include ShareInventoryModule

  let(:isin_info) {create(:isin_info, isin: 'SHPC')}
  let(:other_isin_info) {create(:isin_info, isin: 'SIL')}
  let(:another_isin_info) {create(:isin_info, isin: 'AHPC')}
  let(:voucher) {create(:voucher, fy_code: 7374, date: "2016-12-01", date_bs: "2073-08-16", desc: 'test')}
  let(:other_voucher) {create(:voucher, fy_code: 7374, date: "2016-11-28", date_bs: "2073-08-13", desc: 'test')}
  let(:client_account){create(:client_account, name: 'USER ONE', branch_id: 2, nepse_code: 'SK1')}
  let(:other_client_account){create(:client_account, name: 'USER TWO COMPANY LTD.', branch_id: 1, nepse_code: 'SK2')}
  let(:commission_info) {create(:master_setup_commission_info, start_date: "2016-07-24", end_date: "2021-12-31", start_date_bs: nil, end_date_bs: nil, broker_commission_rate: 80.0, nepse_commission_rate: 20.0)}

  let(:purchase_commission_ledger) {create(:ledger, name: "Purchase Commission")}
  let(:nepse_ledger) {create(:ledger, name: "Nepse Purchase")}
  let(:tds_ledger) {create(:ledger, name: "TDS")}
  let(:dp_ledger) {create(:ledger, name: "DP Fee/ Transfer")}

  let(:particular_client_ledger) {create(:particular, transaction_type: 0, ledger_id: client_account.ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 52000.68, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let(:particular_tds_ledger) {create(:particular, transaction_type: 0, ledger_id: tds_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 92.16, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let(:particular_purchase_commission_ledger) {create(:particular, transaction_type: 1, ledger_id: purchase_commission_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 614.4, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let(:particular_dp_ledger) {create(:particular, transaction_type: 1, ledger_id: dp_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 25.0, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  let(:particular_nepse_ledger) {create(:particular, transaction_type: 1, ledger_id: nepse_ledger.id, name: 'Shares purchased (64*SHPC@800.0) for USER ONE', voucher_id: voucher.id, amount: 51453.44, transaction_date: '2016-12-01', branch_id: client_account.branch_id, fy_code: 7374)}
  subject {FilesImportServices::ImportFloorsheet.new(nil)}

  describe '.process_record_for_full_upload' do
    context 'when single transaction' do
      it 'should return array' do
        client_account
        isin_info
        voucher
        commission_info
        tds_ledger
        purchase_commission_ledger
        dp_ledger
        nepse_ledger
        particular_client_ledger
        particular_tds_ledger
        particular_purchase_commission_ledger
        particular_dp_ledger
        particular_nepse_ledger

        hash_dp_count = {"SK1SHPCbuying"=>1}
        hash_dp = Hash.new
        fy_code = 7374
        settlement_date = '2016-12-06'
        description = "Shares purchased (64*SHPC@800.0) for USER ONE"
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        array = [1.0, 201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8]
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-12-01'.to_date)
        expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(51200.0, 56.32, commission_info).and_return(0.55)
        expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.55, 51200.0).and_return(281.6)
        # allow(import_floorsheet).to receive(:broker_commission).with(768.0, commission_info).and_return(614.4)
        # allow(import_floorsheet).to receive(:nepse_commission_amount).with(768.0, commission_info).and_return(153.6)
        allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 64, true).and_return(true)
        allow(Voucher).to receive(:create!).with(date: '2016-12-01'.to_date, date_bs: '2073-08-16').and_return(voucher)
        allow(import_floorsheet).to receive(:process_accounts).and_return(particular_client_ledger) #default stub
        allow(import_floorsheet).to receive(:process_accounts).with(client_account.ledger, voucher, true, 52000.68, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_client_ledger)
        allow(import_floorsheet).to receive(:process_accounts).with(tds_ledger, voucher, true, 92.16, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_tds_ledger)
        allow(import_floorsheet).to receive(:process_accounts).with(purchase_commission_ledger, voucher, false, 614.4, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_purchase_commission_ledger)
        allow(import_floorsheet).to receive(:process_accounts).with(dp_ledger, voucher, false, 25.0, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_dp_ledger)
        allow(import_floorsheet).to receive(:process_accounts).with(nepse_ledger, voucher, false, 51453.44, description, client_account.branch_id, '2016-12-01'.to_date).and_return(particular_nepse_ledger)
        # expect(import_floorsheet.process_record_for_full_upload(array, hash_dp, fy_code,hash_dp_count,'2016-12-06'.to_date, commission_info)).to eq([201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8, 52000.68, 92.16, 768.0, 51453.44, 25.0, 1, true, '2016-12-01', 1, "7374-1", ShareTransaction.last])
        array_hash = import_floorsheet.relevant_data_hash(array[0..-1])

        result = import_floorsheet.process_record_for_full_upload(array_hash, hash_dp, fy_code,hash_dp_count,'2016-12-06'.to_date, commission_info)
        expect(result[0..array.length-1]).to eq(array)
        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array.length..-1]
        expect(client_dr).to eq(51514.28)
        expect(tds).to eq(33.792)
        expect(commission).to eq(281.6)
        expect(bank_deposit).to eq(51297.792)
        expect(dp).to eq(25.0)
        # expect(bill_id).to eq(1)
        expect(Bill.unscoped.find(bill_id).bill_number).to eq(1)
        expect(is_purchase).to eq(true)
        expect(date).to eq('2016-12-01'.to_date)
        # expect(client_id).to eq(1)
        expect(ClientAccount.find(client_id).name).to eq('USER ONE')
        expect(full_bill_number).to eq('7374-1')
        expect(transaction).to eq(ShareTransaction.last)
      end
    end
    context 'when multiple transactions' do
      it 'returns array' do
        other_client_account
        other_isin_info
        other_voucher
        commission_info
        client_account
        isin_info
        another_isin_info

        hash_dp_count = {"SK1SHPCbuying"=>1, "SK2SILbuying"=>2, "SK2AHPCselling"=>1}
        hash_dp = Hash.new
        fy_code = 7374
        settlement_date = '2016-12-01'
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        array_buying1 = [1.0, 201611284122251.0, "SIL", "99", "55", "USER TWO COMPANY LTD.", "SK2", 10.0, 2049.0, 20490.0, 24.59, 20532.42]
        array_buying2 = [2.0, 201611284121822.0, "SIL", "99", "28", "USER TWO COMPANY LTD.", "SK2", 55.0, 1875.0, 103125.0, 113.44, 103321.97]
        array_buying3 = [3.0, 201611284121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 364.0, 770.0, 280280.0, 308.31, 280815.34]
        array_selling = [4.0, 201611284121163.0, "AHPC", "99", "99", "USER TWO COMPANY LTD.", "SK2", 10.0, 240.0, 2400.0, 5.0, nil]
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)

        # for first buying transaction
        expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(20490.0, 24.59, commission_info).and_return(0.6)
        expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.6, 20490.0).and_return(122.94)
        # allow(import_floorsheet).to receive(:broker_commission).with(307.35, commission_info).and_return(245.88)
        # allow(import_floorsheet).to receive(:nepse_commission_amount).with(307.35, commission_info).and_return(61.47)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, other_isin_info.id, 10, true).and_return(true)
        allow(Voucher).to receive(:create!).with(date: '2016-11-28'.to_date, date_bs: '2073-08-13').and_return(other_voucher)
        # expect(import_floorsheet.process_record_for_full_upload(array_buying2, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)).to eq('')
        new_array_buying1 = import_floorsheet.relevant_data_hash(array_buying1[0..-1])
        result = import_floorsheet.process_record_for_full_upload(new_array_buying1, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying1.length-1]).to eq(array_buying1)
        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying1.length..-1]
        expect(client_dr).to eq(20628.5135)
        expect(tds).to be_within(0.1).of(14.75)
        expect(commission).to eq(122.94)
        expect(bank_deposit).to eq(20532.416)
        expect(dp).to eq(12.5)
        expect(Bill.unscoped.find(bill_id).bill_number).to eq(1)
        expect(is_purchase).to eq(true)
        expect(date).to eq('2016-11-28'.to_date)
        # expect(client_id).to eq(1)
        expect(ClientAccount.find(client_id).name).to eq('USER TWO COMPANY LTD.')
        expect(full_bill_number).to eq('7374-1')
        expect(transaction).to eq(ShareTransaction.last)
        expect(ShareTransaction.count).to eq(1)

        # for second buying transaction
        expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(103125.0, 113.44, commission_info).and_return(0.55)
        expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.55, 103125.0).and_return(567.19)
        # allow(import_floorsheet).to receive(:broker_commission).with(1546.875, commission_info).and_return(1237.5)
        # allow(import_floorsheet).to receive(:nepse_commission_amount).with(1546.875, commission_info).and_return(309.375)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, other_isin_info.id, 55, true).and_return(true)
        new_array_buying2 = import_floorsheet.relevant_data_hash(array_buying2[0..-1])
        result = import_floorsheet.process_record_for_full_upload(new_array_buying2, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying2.length-1]).to eq(array_buying2)
        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying2.length..-1]
        expect(client_dr).to eq(103720.15875)
        expect(tds).to eq(68.0625)
        expect(commission).to eq(567.19)
        expect(bank_deposit).to eq(103321.97125)
        expect(dp).to eq(12.5)
        expect(Bill.unscoped.find(bill_id).bill_number).to eq(1)
        expect(is_purchase).to eq(true)
        expect(date).to eq('2016-11-28'.to_date)
        # expect(client_id).to eq(1)
        expect(ClientAccount.find(client_id).name).to eq('USER TWO COMPANY LTD.')
        expect(full_bill_number).to eq('7374-1')
        expect(transaction).to eq(ShareTransaction.last)
        expect(ShareTransaction.count).to eq(2)

        # for third buying transaction
        expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(280280.0, 308.31, commission_info).and_return(0.55)
        expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.55, 280280.0).and_return(1541.54)
        # allow(import_floorsheet).to receive(:broker_commission).with(4204.2, commission_info).and_return(3363.36)
        # allow(import_floorsheet).to receive(:nepse_commission_amount).with(4204.2, commission_info).and_return(840.84)
        allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 364, true).and_return(true)
        new_array_buying3 = import_floorsheet.relevant_data_hash(array_buying3[0..-1])
        result = import_floorsheet.process_record_for_full_upload(new_array_buying3, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying3.length-1]).to eq(array_buying3)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying3.length..-1]

        expect(client_dr).to eq(281888.58199999994)
        expect(tds).to eq(184.9845)
        expect(commission).to eq(1541.54)
        expect(bank_deposit).to eq(280815.3365)
        expect(dp).to eq(25.0)
        expect(Bill.unscoped.find(bill_id).bill_number).to eq(2)
        expect(is_purchase).to eq(true)
        expect(date).to eq('2016-11-28'.to_date)
        # expect(client_id).to eq(2)
        expect(ClientAccount.find(client_id).name).to eq('USER ONE')
        expect(full_bill_number).to eq('7374-2')
        expect(transaction).to eq(ShareTransaction.last)
        expect(ShareTransaction.count).to eq(3)

        # for selling transction
        expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(2400.0, 5.0, commission_info).and_return("flat_25")
        expect(import_floorsheet).to receive(:get_commission_by_rate).with("flat_25", 2400.0).and_return(25.0)
        # allow(import_floorsheet).to receive(:broker_commission).with(36.0, commission_info).and_return(28.8)
        # allow(import_floorsheet).to receive(:nepse_commission_amount).with(36.0, commission_info).and_return(7.2)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, another_isin_info.id, 10, false).and_return(true)

        new_array_selling = import_floorsheet.relevant_data_hash(array_selling[0..-1])
        result = import_floorsheet.process_record_for_full_upload(new_array_selling, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_selling.length-1]).to eq(array_selling)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_selling.length..-1]
        expect(client_dr).to eq(2450.36)
        expect(tds).to eq(3.0)
        expect(commission).to eq(25.0)
        expect(bank_deposit).to eq(2408.36)
        expect(dp).to eq(25.0)
        expect(bill_id).to eq(nil)
        expect(is_purchase).to eq(false)
        expect(date).to eq('2016-11-28'.to_date)
        # expect(client_id).to eq(1)
        expect(ClientAccount.find(client_id).name).to eq('USER TWO COMPANY LTD.')
        expect(full_bill_number).to eq(nil)
        expect(transaction).to eq(ShareTransaction.last)
        expect(ShareTransaction.count).to eq(4)
      end
    end
  end

  describe '.process_record_for_partial_upload' do
    let!(:client_account3){create(:client_account, name: 'USER THREE', nepse_code: 'SK3')}
    let!(:client_account4){create(:client_account, name: 'USER FOUR', nepse_code: 'SK4')}
    let!(:client_account5){create(:client_account, name: 'USER FIVE', nepse_code: 'SK5')}
    let!(:client_account6){create(:client_account, name: 'USER SIX', nepse_code: 'SK6')}
    let!(:commission_info) {create(:master_setup_commission_info, start_date: "2016-07-24", end_date: "2021-12-31", start_date_bs: nil, end_date_bs: nil, broker_commission_rate: 80.0, nepse_commission_rate: 20.0)}
    it 'returns array' do
      other_client_account
      other_isin_info
      voucher
      client_account
      isin_info
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      import_floorsheet.process
      expect(ShareTransaction.count).to eq(24)
      expect(FileUpload.count).to eq(1)
      expect(Bill.count).to eq(1)

      hash_dp_count = {"SK1SHPCbuying"=>1, "SK2SILbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      array_not_in_partial = [201611284121137.0, "SHPC", "99", "32", "USER ONE", "SK1", 15.0, 760.0, 11400.0, 13.68, 11423.6]
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
      import_floorsheet.instance_variable_set(:@bill_number, 2)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      # having pre_processed_relevant_share_transactions
      expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(11400.0, 13.68, commission_info).and_return(0.6).ordered
      expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.6, 11400.0).and_return(68.4).ordered
      # allow(import_floorsheet).to receive(:broker_commission).with(68.4, commission_info).and_return(54.72)
      # allow(import_floorsheet).to receive(:nepse_commission_amount).with(68.4, commission_info).and_return(13.68)
      allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 15, true).and_return(true)
      allow(Voucher).to receive(:create!).with(date: '2016-11-28'.to_date, date_bs: '2073-08-13').and_return(other_voucher)
      new_array_not_in_partial = array_not_in_partial[0..-1]
      result = import_floorsheet.process_record_for_partial_upload(new_array_not_in_partial, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)
      expect(result[0..array_not_in_partial.length-1]).to eq(array_not_in_partial)

      client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_not_in_partial.length..-1]
      expect(client_dr).to be_within(0.2).of(11495)
      expect(tds).to eq(8.208)
      expect(commission).to eq(68.4)
      expect(bank_deposit).to be_within(0.01).of(11423.6)
      expect(dp).to eq(25.0)
      # bill_id =1, bill_number = 1
      expect(Bill.unscoped.find(bill_id).bill_number).to eq(2)
      expect(is_purchase).to eq(true)
      expect(date).to eq('2016-11-28'.to_date)
      # expect(client_id).to eq(1)
      expect(ClientAccount.find(client_id).name).to eq('USER ONE')
      expect(full_bill_number).to eq('7374-2')
      expect(transaction).to eq(ShareTransaction.where(contract_no: 201611284121137.0).first)
      expect(ShareTransaction.count).to eq(25)

      # not having pre_processed_relevant_share_transactions
      array_not_in_partial1 = [201611284121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 364.0, 770.0, 280280.0, 308.31, 280815.34]
      expect(import_floorsheet).to receive(:get_commission_rate_from_floorsheet).with(280280.0, 308.31, commission_info).and_return(0.55).ordered
      expect(import_floorsheet).to receive(:get_commission_by_rate).with(0.55, 280280.0).and_return(1541.54).ordered
      # allow(import_floorsheet).to receive(:broker_commission).with(4204.2, commission_info).and_return(3363.36)
      # allow(import_floorsheet).to receive(:nepse_commission_amount).with(4204.2, commission_info).and_return(840.84)
      allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 364, true).and_return(true)
      new_array_not_in_partial1 = array_not_in_partial1[0..-1]
      result = import_floorsheet.process_record_for_partial_upload(new_array_not_in_partial1, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

      expect(result[0..array_not_in_partial1.length-1]).to eq(array_not_in_partial1)

      client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_not_in_partial1.length..-1]
      expect(client_dr).to be_within(0.1).of(281888.5855)
      expect(tds).to be_within(0.1).of(184.9845)
      expect(commission).to be_within(0.1).of(1541.54)
      expect(bank_deposit).to be_within(0.1).of(280815.34)
      expect(dp).to eq(25.0)
      expect(Bill.unscoped.find(bill_id).bill_number).to eq(2)
      expect(is_purchase).to eq(true)
      expect(date).to eq('2016-11-28'.to_date)
      # expect(client_id).to eq(2)
      expect(ClientAccount.find(client_id).name).to eq('USER ONE')
      expect(full_bill_number).to eq('7374-2')
      expect(transaction).to eq(ShareTransaction.where(contract_no: 201611284121143.0).first)
      expect(ShareTransaction.count).to eq(26)
    end
  end

  describe '.repatch_share_transactions_accomodating_partial_upload' do
    let!(:client_account3){create(:client_account, name: 'USER THREE', nepse_code: 'SK3')}
    let!(:client_account4){create(:client_account, name: 'USER FOUR', nepse_code: 'SK4')}
    let!(:client_account5){create(:client_account, name: 'USER FIVE', nepse_code: 'SK5')}
    let!(:client_account6){create(:client_account, name: 'USER SIX', nepse_code: 'SK6')}
    let!(:commission_info) {create(:master_setup_commission_info, start_date: "2016-07-24", end_date: "2021-12-31", start_date_bs: nil, end_date_bs: nil, broker_commission_rate: 80.0, nepse_commission_rate: 20.0)}
    it 'updates share transaction' do
      client_account
      other_client_account
      commission_info
      hash_dp_count = {"SK1SHPCbuying"=>1, "SK2SILbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      array = [201611284122251, "SIL", "99", "55", "USER TWO COMPANY LTD.", "SK2", 10.0, 2049.0, 20490.0, 24.59, 20532.42]
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      import_floorsheet.process
      processed_share_transactions_for_the_date = ShareTransaction.all
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
      import_floorsheet.instance_variable_set(:@bill_number, 2)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      import_floorsheet.process_record_for_partial_upload(array, hash_dp, fy_code, hash_dp_count,'2016-12-01'.to_date, commission_info)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.dp_fee).to eq(3.5714)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.net_amount).to eq(20217.1249)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.dp_fee).to eq(25.0)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.net_amount).to eq(20641.0135)
      expect(Voucher.count).to eq(8)
      repatched_share_transactions = import_floorsheet.repatch_share_transactions_accomodating_partial_upload(processed_share_transactions_for_the_date)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.dp_fee).to eq(3.125)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.net_amount).to eq(20216.6785)
      expect(Voucher.where(voucher_number: 9).first.desc).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')
      expect(Voucher.where(voucher_number: 9).first.particulars.first.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')
      expect(Voucher.where(voucher_number: 9).first.particulars.last.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')

      expect(ShareTransaction.where(contract_no: 201611284122251).first.dp_fee).to eq(3.125)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.net_amount).to eq(20619.1385)
      expect(Voucher.last.desc).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
      expect(Voucher.last.particulars.first.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
      expect(Voucher.last.particulars.last.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
    end
  end

  describe '.process_full_partial' do
    let(:client_account3){create(:client_account, name: 'USER THREE', nepse_code: 'SK3')}
    let(:client_account4){create(:client_account, name: 'USER FOUR', nepse_code: 'SK4')}
    let(:client_account5){create(:client_account, name: 'USER FIVE', nepse_code: 'SK5')}
    let(:client_account6){create(:client_account, name: 'USER SIX', nepse_code: 'SK6')}

    it 'uploads file' do
      client_account
      other_client_account
      client_account3
      client_account4
      client_account5
      client_account6
      commission_info
      file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
      import_floorsheet.instance_variable_set(:@bill_number, 1)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      xlsx = Roo::Spreadsheet.open(file, extension: :xml)
      # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      # settlement_date = '2016-12-01'
      allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
      expect(import_floorsheet.process_full_partial(false)).to eq(FileUpload.last)
      expect(FileUpload.count).to eq(1)
    end

    context 'when new client accounts present' do
      it 'returns error message' do
        commission_info
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xml)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full_partial(false)).to eq(nil)
        expect(import_floorsheet.error_message).to eq("FLOORSHEET IMPORT CANCELLED!<br>New client accounts found in the file!<br>Please manually create the client accounts for the following in the system first, before re-uploading the floorsheet.<br>If applicable, please make sure to assign the correct branch to the client account so that billing is tagged to the appropriate branch.<br>")
        expect(import_floorsheet.error_type).to eq('new_client_accounts_present')
        expect(FileUpload.count).to eq(0)
      end
    end

    context 'when file already uploaded' do
      it 'returns error' do
        client_account
        other_client_account
        client_account3
        client_account4
        client_account5
        client_account6
        commission_info
        FileUpload.create(file_type: 1, report_date: '2016-11-28'.to_date)
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xml)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full_partial(false)).to eq(nil)
        expect(import_floorsheet.error_message).to eq('The file is already uploaded')
        expect(FileUpload.count).to eq(1)
      end
    end

    context 'when date not valid for fy_code' do
      it 'returns error' do
        client_account
        other_client_account
        client_account3
        client_account4
        client_account5
        client_account6
        commission_info
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        UserSession.selected_fy_code = 7475
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xml)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full_partial(false)).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please change the fiscal year.')
        expect(FileUpload.count).to eq(0)
      end
    end

    context 'when invalid file' do
      it 'returns error message' do
        client_account
        other_client_account
        client_account3
        client_account4
        client_account5
        client_account6
        invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_incorrect_total_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file)
        xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xml)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        # settlement_date = '2016-12-01'
        expect(import_floorsheet.process_full_partial(false)).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please verify and Upload a valid file')
        expect(FileUpload.count).to eq(0)
      end
    end
  end

  describe '.process_full_partial(true)' do
    let(:client_account3){create(:client_account, name: 'USER THREE', nepse_code: 'SK3')}
    let(:client_account4){create(:client_account, name: 'USER FOUR', nepse_code: 'SK4')}
    let(:client_account5){create(:client_account, name: 'USER FIVE', nepse_code: 'SK5')}
    let(:client_account6){create(:client_account, name: 'USER SIX', nepse_code: 'SK6')}
    it 'uploads partial file' do
      other_client_account
      client_account
      commission_info
      client_account3
      client_account4
      client_account5
      client_account6
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      import_floorsheet.process
      expect(FileUpload.count).to eq(1)
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
      import_floorsheet.instance_variable_set(:@bill_number, 2)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      xlsx = Roo::Spreadsheet.open(file, extension: :xml)
      allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
      expect(import_floorsheet.process_full_partial(true)).to eq(FileUpload.last)
      expect(FileUpload.count).to eq(1)
    end

    context 'when new client accounts present' do
      it 'returns error message' do
        other_client_account
        commission_info
        client_account3
        client_account4
        client_account5
        client_account6
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        expect(FileUpload.count).to eq(1)
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
        import_floorsheet.instance_variable_set(:@bill_number, 2)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xml)
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full_partial(true)).to eq(nil)
        expect(import_floorsheet.error_message).to eq("FLOORSHEET IMPORT CANCELLED!<br>New client accounts found in the file!<br>Please manually create the client accounts for the following in the system first, before re-uploading the floorsheet.<br>If applicable, please make sure to assign the correct branch to the client account so that billing is tagged to the appropriate branch.<br>")
        expect(import_floorsheet.error_type).to eq('new_client_accounts_present')
        expect(FileUpload.count).to eq(1)
      end
    end

    context 'when date not valid for fy_code' do
      it 'returns error message' do
        other_client_account
        client_account
        commission_info
        client_account3
        client_account4
        client_account5
        client_account6
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
        file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        expect(FileUpload.count).to eq(1)
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        UserSession.selected_fy_code = 7475
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
        import_floorsheet.instance_variable_set(:@bill_number, 2)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xml)
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full_partial(true)).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please change the fiscal year.')
        expect(FileUpload.count).to eq(1)
      end
    end

    context 'when invalid file' do
      it 'returns error message' do
        other_client_account
        client_account
        commission_info
        client_account3
        client_account4
        client_account5
        client_account6
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_partial_2073-08-13.xls')
        invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_incorrect_total_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file, true)
        xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xml)
        expect(import_floorsheet.process_full_partial(true)).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please verify and Upload a valid file')
      end
    end
  end

  describe '.is_invalid_file_data' do
    it 'returns true' do
      invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/v2/floor_sheet_broker_99_small_incorrect_total_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file)
      xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xml)
      expect(import_floorsheet.is_invalid_file_data(xlsx)).to eq(true)
    end
  end

  describe '.get_bill_number' do
    it 'should return bill number' do
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(nil)
      expect(import_floorsheet.get_bill_number(7374)).to eq(1)
    end
  end
  describe '.bill' do
    context "when bill_number, fy_code, date, client_account_id exits " do
      it "returns existing bill" do
        bill = create(:bill)
        expect(subject.find_or_create_bill(bill.bill_number,
                                           bill.fy_code,
                                           bill.date,
                                           bill.client_account_id)).to eq(bill)
      end
      it "returns new bill" do
        expect{subject.find_or_create_bill("001",'7374','10/02/2016',1)}
      end
    end
  end

  describe '. add_client_account' do
    context 'when client account includes client account hash' do
      it 'adds client account hash to client account' do
        new_client_accounts = []
        expect(subject.add_client_account("ram",123,new_client_accounts)
              ).to eq([{client_name: "ram",client_nepse_code: 123}])
      end
    end
    context 'when client account does not include client account hash' do
      it "does not add client account hash to client account" do
        new_client_accounts = [{:client_name=>"ram", :client_nepse_code=>123}]
        expect(subject.add_client_account("ram",123,new_client_accounts)).to eq(nil)
      end
    end
  end
  describe '.hash_dp_count_increment' do
    it "increment count if hash_dp" do
      share_transactions = create(:share_transaction, date: '2018-10-02',
                                                      client_account_id: client_account.id,
                                                      isin_info: isin_info,
                                                      transaction_type: 1)
      hash_dp_count = Hash.new
      expect {subject.hash_dp_count_increment('selling',client_account,isin_info.isin,"1234",hash_dp_count)
      }.to change{hash_dp_count.count}.by(2)
    end
  end
  describe '.relevant_share_transactions_count' do
    it "counts number of share transaction" do
      share_transactions = create(:share_transaction, date: '2018-10-02',
                                                      client_account_id: client_account.id,
                                                      isin_info: isin_info,
                                                      transaction_type: 1)
      expect(subject.relevant_share_transactions_count('2018-10-02',
                                                        client_account.id,isin_info.id,1)).to eq(1)
    end
  end
  describe '.find_or_create_ledger_by_name' do
    subject {FilesImportServices::ImportFloorsheet.new(nil)}
    context "when ledger exits " do

      it "returns existing ledger" do
        ledger = create(:ledger)
        expect(subject.find_or_create_ledger_by_name(ledger.name)).to eq(ledger)

      end
    end
    context "when ledger with name does not exits" do
      it "creates new ledger" do
        expect{subject.find_or_create_ledger_by_name("john")}.to change{Ledger.count}.by(1)
      end
    end
  end
end
