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
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-15.xls')
        array = [201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8]
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-12-01'.to_date)
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
        # expect(import_floorsheet.process_record_for_full_upload(array, hash_dp, fy_code,hash_dp_count,'2016-12-06'.to_date, commission_info)).to eq([201612014121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 64.0, 800.0, 51200.0, 56.32, 51297.8, 52000.68, 92.16, 768.0, 51453.44, 25.0, 1, true, '2016-12-01', 1, "7374-1", ShareTransaction.last])
        new_array = array[0..-1]
        result = import_floorsheet.process_record_for_full_upload(new_array, hash_dp, fy_code,hash_dp_count,'2016-12-06'.to_date, commission_info)

        expect(result[0..array.length-1]).to eq(array)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array.length..-1]
        expect(client_dr).to eq(52000.68)
        expect(tds).to eq(92.16)
        expect(commission).to eq(768.0)
        expect(bank_deposit).to eq(51453.44)
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
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        array_buying1 = [201611284122251.0, "SIL", "99", "55", "USER TWO COMPANY LTD.", "SK2", 10.0, 2049.0, 20490.0, 24.59, 20532.42]
        array_buying2 = [201611284121822.0, "SIL", "99", "28", "USER TWO COMPANY LTD.", "SK2", 55.0, 1875.0, 103125.0, 113.44, 103321.97]
        array_buying3 = [201611284121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 364.0, 770.0, 280280.0, 308.31, 280815.34]
        array_selling = [201611284121163.0, "AHPC", "99", "99", "USER TWO COMPANY LTD.", "SK2", 10.0, 240.0, 2400.0, 5.0, nil]
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)

        # for first buying transaction
        allow(import_floorsheet).to receive(:get_commission).with(20490.0, commission_info).and_return(307.35)
        allow(import_floorsheet).to receive(:get_commission_rate).with(20490.0, commission_info).and_return(1.5)
        allow(import_floorsheet).to receive(:broker_commission).with(307.35, commission_info).and_return(245.88)
        allow(import_floorsheet).to receive(:nepse_commission_amount).with(307.35, commission_info).and_return(61.47)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, other_isin_info.id, 10, true).and_return(true)
        allow(Voucher).to receive(:create!).with(date: '2016-11-28'.to_date, date_bs: '2073-08-13').and_return(other_voucher)
        # expect(import_floorsheet.process_record_for_full_upload(array_buying2, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)).to eq('')
        new_array_buying1 = array_buying1[0..-1]
        result = import_floorsheet.process_record_for_full_upload(new_array_buying1, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying1.length-1]).to eq(array_buying1)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying1.length..-1]
        expect(client_dr).to eq(20812.9235)
        expect(tds).to eq(36.882)
        expect(commission).to eq(307.35)
        expect(bank_deposit).to eq(20591.4255)
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
        allow(import_floorsheet).to receive(:get_commission).with(103125.0, commission_info).and_return(1546.875)
        allow(import_floorsheet).to receive(:get_commission_rate).with(103125.0, commission_info).and_return(1.5)
        allow(import_floorsheet).to receive(:broker_commission).with(1546.875, commission_info).and_return(1237.5)
        allow(import_floorsheet).to receive(:nepse_commission_amount).with(1546.875, commission_info).and_return(309.375)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, other_isin_info.id, 55, true).and_return(true)
        new_array_buying2 = array_buying2[0..-1]
        result = import_floorsheet.process_record_for_full_upload(new_array_buying2, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying2.length-1]).to eq(array_buying2)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying2.length..-1]
        expect(client_dr).to eq(104699.84375)
        expect(tds).to eq(185.625)
        expect(commission).to eq(1546.875)
        expect(bank_deposit).to eq(103635.46875)
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
        allow(import_floorsheet).to receive(:get_commission).with(280280.0, commission_info).and_return(4204.2)
        allow(import_floorsheet).to receive(:get_commission_rate).with(280280.0, commission_info).and_return(1.5)
        allow(import_floorsheet).to receive(:broker_commission).with(4204.2, commission_info).and_return(3363.36)
        allow(import_floorsheet).to receive(:nepse_commission_amount).with(4204.2, commission_info).and_return(840.84)
        allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 364, true).and_return(true)
        new_array_buying3 = array_buying3[0..-1]
        result = import_floorsheet.process_record_for_full_upload(new_array_buying3, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_buying3.length-1]).to eq(array_buying3)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_buying3.length..-1]
        expect(client_dr).to eq(284551.24199999997)
        expect(tds).to eq(504.504)
        expect(commission).to eq(4204.2)
        expect(bank_deposit).to eq(281667.386)
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
        allow(import_floorsheet).to receive(:get_commission).with(2400.0, commission_info).and_return(36.0)
        allow(import_floorsheet).to receive(:get_commission_rate).with(2400.0, commission_info).and_return(1.5)
        allow(import_floorsheet).to receive(:broker_commission).with(36.0, commission_info).and_return(28.8)
        allow(import_floorsheet).to receive(:nepse_commission_amount).with(36.0, commission_info).and_return(7.2)
        allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, another_isin_info.id, 10, false).and_return(true)

        new_array_selling = array_selling[0..-1]
        result = import_floorsheet.process_record_for_full_upload(new_array_selling, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

        expect(result[0..array_selling.length-1]).to eq(array_selling)

        client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_selling.length..-1]
        expect(client_dr).to eq(2461.36)
        expect(tds).to eq(4.32)
        expect(commission).to eq(36.0)
        expect(bank_deposit).to eq(2411.88)
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
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      import_floorsheet.process
      expect(ShareTransaction.count).to eq(24)
      expect(FileUpload.count).to eq(1)
      expect(Bill.count).to eq(1)

      hash_dp_count = {"SK1SHPCbuying"=>1, "SK2SILbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      array_not_in_partial = [201611284122251.0, "SIL", "99", "55", "USER TWO COMPANY LTD.", "SK2", 10.0, 2049.0, 20490.0, 24.59, 20532.42]
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
      import_floorsheet.instance_variable_set(:@bill_number, 2)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      # having pre_processed_relevant_share_transactions
      allow(import_floorsheet).to receive(:get_commission).with(20490.0, commission_info).and_return(307.35)
      allow(import_floorsheet).to receive(:get_commission_rate).with(20490.0, commission_info).and_return(1.5)
      allow(import_floorsheet).to receive(:broker_commission).with(307.35, commission_info).and_return(245.88)
      allow(import_floorsheet).to receive(:nepse_commission_amount).with(307.35, commission_info).and_return(61.47)
      allow(import_floorsheet).to receive(:update_share_inventory).with(other_client_account.id, other_isin_info.id, 10, true).and_return(true)
      allow(Voucher).to receive(:create!).with(date: '2016-11-28'.to_date, date_bs: '2073-08-13').and_return(other_voucher)
      new_array_not_in_partial = array_not_in_partial[0..-1]
      result = import_floorsheet.process_record_for_partial_upload(new_array_not_in_partial, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

      expect(result[0..array_not_in_partial.length-1]).to eq(array_not_in_partial)

      client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_not_in_partial.length..-1]
      expect(client_dr).to eq(20825.4235)
      expect(tds).to eq(36.882)
      expect(commission).to eq(307.35)
      expect(bank_deposit).to eq(20591.4255)
      expect(dp).to eq(25.0)
      # bill_id =1, bill_number = 1
      expect(Bill.unscoped.find(bill_id).bill_number).to eq(1)
      expect(is_purchase).to eq(true)
      expect(date).to eq('2016-11-28'.to_date)
      # expect(client_id).to eq(1)
      expect(ClientAccount.find(client_id).name).to eq('USER TWO COMPANY LTD.')
      expect(full_bill_number).to eq('7374-1')
      expect(transaction).to eq(ShareTransaction.where(contract_no: 201611284122251.0).first)
      expect(ShareTransaction.count).to eq(25)


      # not having pre_processed_relevant_share_transactions
      array_not_in_partial1 = [201611284121143.0, "SHPC", "99", "42", "USER ONE", "SK1", 364.0, 770.0, 280280.0, 308.31, 280815.34]
      allow(import_floorsheet).to receive(:get_commission).with(280280.0, commission_info).and_return(4204.2)
      allow(import_floorsheet).to receive(:get_commission_rate).with(280280.0, commission_info).and_return(1.5)
      allow(import_floorsheet).to receive(:broker_commission).with(4204.2, commission_info).and_return(3363.36)
      allow(import_floorsheet).to receive(:nepse_commission_amount).with(4204.2, commission_info).and_return(840.84)
      allow(import_floorsheet).to receive(:update_share_inventory).with(client_account.id, isin_info.id, 364, true).and_return(true)
      new_array_not_in_partial1 = array_not_in_partial1[0..-1]
      result = import_floorsheet.process_record_for_partial_upload(new_array_not_in_partial1, hash_dp, fy_code,hash_dp_count,'2016-12-01'.to_date, commission_info)

      expect(result[0..array_not_in_partial1.length-1]).to eq(array_not_in_partial1)

      client_dr, tds, commission, bank_deposit, dp, bill_id, is_purchase, date, client_id, full_bill_number, transaction = result[array_not_in_partial1.length..-1]
      expect(client_dr).to eq(284551.24199999997)
      expect(tds).to eq(504.504)
      expect(commission).to eq(4204.2)
      expect(bank_deposit).to eq(281667.386)
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
      hash_dp_count = {"SK2SILbuying"=>1}
      hash_dp = Hash.new
      fy_code = 7374
      array = [201611284122251, "SIL", "99", "55", "USER TWO COMPANY LTD.", "SK2", 10.0, 2049.0, 20490.0, 24.59, 20532.42]
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
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
      expect(ShareTransaction.where(contract_no: 201611284122142).first.net_amount).to eq(20397.9349)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.dp_fee).to eq(25.0)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.net_amount).to eq(20825.4235)
      expect(Voucher.count).to eq(8)
      repatched_share_transactions = import_floorsheet.repatch_share_transactions_accomodating_partial_upload(processed_share_transactions_for_the_date)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.dp_fee).to eq(3.125)
      expect(ShareTransaction.where(contract_no: 201611284122142).first.net_amount).to eq(20397.4885)
      expect(Voucher.where(voucher_number: 9).first.desc).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')
      expect(Voucher.where(voucher_number: 9).first.particulars.first.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')
      expect(Voucher.where(voucher_number: 9).first.particulars.last.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122142 due to partial uploads for 2073-08-13.')

      expect(ShareTransaction.where(contract_no: 201611284122251).first.dp_fee).to eq(3.125)
      expect(ShareTransaction.where(contract_no: 201611284122251).first.net_amount).to eq(20803.5485)
      expect(Voucher.last.desc).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
      expect(Voucher.last.particulars.first.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
      expect(Voucher.last.particulars.last.name).to eq('Reverse entry to accomodate dp fee for transaction number 201611284122251 due to partial uploads for 2073-08-13.')
    end
  end

  describe '.process_full' do
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
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
      import_floorsheet.instance_variable_set(:@bill_number, 1)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      xlsx = Roo::Spreadsheet.open(file, extension: :xls)
      # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      # settlement_date = '2016-12-01'
      allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
      expect(import_floorsheet.process_full).to eq(FileUpload.last)
      expect(FileUpload.count).to eq(1)
    end

    context 'when new client accounts present' do
      it 'returns error message' do
        commission_info
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xls)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full).to eq(nil)
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
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xls)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full).to eq(nil)
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
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        UserSession.selected_fy_code = 7475
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file)
        import_floorsheet.instance_variable_set(:@bill_number, 1)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xls)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        # settlement_date = '2016-12-01'
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_full).to eq(nil)
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
        invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_invalid_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file)
        xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xls)
        # allow(import_floorsheet).to receive(:is_invalid_file_data).with(xlsx).and_return(false)
        # settlement_date = '2016-12-01'
        expect(import_floorsheet.process_full).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please verify and Upload a valid file')
        expect(FileUpload.count).to eq(0)
      end
    end
  end

  describe '.process_partial' do
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
      file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
      file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
      allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
      import_floorsheet.process
      expect(FileUpload.count).to eq(1)
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
      import_floorsheet.instance_variable_set(:@bill_number, 2)
      import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
      xlsx = Roo::Spreadsheet.open(file, extension: :xls)
      allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
      expect(import_floorsheet.process_partial).to eq(FileUpload.last)
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
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        expect(FileUpload.count).to eq(1)
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
        import_floorsheet.instance_variable_set(:@bill_number, 2)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xls)
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_partial).to eq(nil)
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
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
        file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        expect(FileUpload.count).to eq(1)
        commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
        UserSession.selected_fy_code = 7475
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file, true)
        import_floorsheet.instance_variable_set(:@bill_number, 2)
        import_floorsheet.instance_variable_set(:@date, '2016-11-28'.to_date)
        xlsx = Roo::Spreadsheet.open(file, extension: :xls)
        allow(import_floorsheet).to receive(:get_commission_info_with_detail).with('2016-11-28'.to_date).and_return(commission_info)
        expect(import_floorsheet.process_partial).to eq(nil)
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
        file_partial = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_small_partial_2073-08-13.xls')
        invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_invalid_2073-08-13.xls')
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(file_partial)
        allow(Calendar).to receive(:t_plus_3_trading_days).with('2016-11-28'.to_date).and_return('2016-12-01')
        import_floorsheet.process
        import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file, true)
        xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xls)
        expect(import_floorsheet.process_partial).to eq(nil)
        expect(import_floorsheet.error_message).to eq('Please verify and Upload a valid file')
      end
    end
  end

  describe '.is_invalid_file_data' do
    it 'returns true' do
      invalid_file = (Rails.root + 'test/fixtures/files/floorsheets/BrokerwiseFloorSheetReport_invalid_2073-08-13.xls')
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(invalid_file)
      xlsx = Roo::Spreadsheet.open(invalid_file, extension: :xls)
      expect(import_floorsheet.is_invalid_file_data(xlsx)).to eq(true)
    end
  end

  describe '.get_bill_number' do
    it 'should return bill number' do
      import_floorsheet = FilesImportServices::ImportFloorsheet.new(nil)
      expect(import_floorsheet.get_bill_number(7374)).to eq(1)
    end
  end
end