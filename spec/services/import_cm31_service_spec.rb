require 'rails_helper'

RSpec.describe FilesImportServices::ImportCm31  do
  let(:nepse_settlement) {create(:nepse_settlement)}
  let(:share_transaction) {create(:share_transaction)}
  let(:nepse_ledger){ Ledger.find_or_create_by!(name: "Nepse Purchase")}

  before do
    UserSession.user = create(:user)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374
    # allow_any_instance_of(GenerateBillsService).to receive(:broker_commission_rate).and_return(0.8)
  end

  context "automatic settlement by system" do
    it 'should do the ledger entry' do
      share_transaction
      allow_any_instance_of(FilesImportServices::ImportCm31).to receive(:open_file).and_return(nil)
      import_cm31_service = FilesImportServices::ImportCm31.new(nil, Tenant.new(closeout_settlement_automatic: true),'2073-9-5')
      import_cm31_service.instance_variable_set(:@processed_data,[{"SETTLEMENTID"=>"1211002016255", "CONTRACTNUMBER"=>"201611284117936", "SELLERCM"=>"42", "SELLERCLIENT"=>"SK1", "BUYERCM"=>"99", "BUYERCLIENT"=>"JD221527", "ISIN"=>"NPE011A00004", "SCRIPNAME"=>"SHPC", "TRADEDQTY"=>"185", "SHORTAGEQTY"=>"20", "RATE"=>"626", "CLOSEOUTCRAMT"=>"15024"}])

      import_cm31_service.process
      # expect(Voucher.count).to eq 2
      # expect(share_transaction.client_account.ledger.closing_balance).to eq(-15024)
      # expect(nepse_ledger.closing_balance).to eq(15024)
      # closeout_ledger = Ledger.find_by(name: "Close Out")
      # expect(closeout_ledger.present?).to be_truthy
      # expect(closeout_ledger.closing_balance).to eq(0)
      # expect(closeout_ledger.particulars.count).to eq(2)
      # expect(share_transaction.reload.closeout_settled).to be_truthy
      expect(Voucher.count).to eq 1
      # no effect on client ledger
      expect(share_transaction.client_account.ledger.closing_balance).to eq(0)
      expect(nepse_ledger.closing_balance).to eq(15024)
      closeout_ledger = Ledger.find_by(name: "Close Out")
      expect(closeout_ledger.present?).to be_truthy
      expect(closeout_ledger.closing_balance).to eq(-15024)
      expect(closeout_ledger.particulars.count).to eq(1)
      expect(share_transaction.reload.closeout_settled).to_not be_truthy
    end

  end

  context "manual interventions for closeouts" do
    it 'should do ledger entry' do
      share_transaction
      allow_any_instance_of(FilesImportServices::ImportCm31).to receive(:open_file).and_return(nil)
      import_cm31_service = FilesImportServices::ImportCm31.new(nil, Tenant.new(closeout_settlement_automatic: false),'2073-9-5')
      import_cm31_service.instance_variable_set(:@processed_data,[{"SETTLEMENTID"=>"1211002016255", "CONTRACTNUMBER"=>"201611284117936", "SELLERCM"=>"42", "SELLERCLIENT"=>"SK1", "BUYERCM"=>"99", "BUYERCLIENT"=>"JD221527", "ISIN"=>"NPE011A00004", "SCRIPNAME"=>"SHPC", "TRADEDQTY"=>"185", "SHORTAGEQTY"=>"20", "RATE"=>"626", "CLOSEOUTCRAMT"=>"15024"}])

      import_cm31_service.process
      expect(Voucher.count).to eq 1
      # no effect on client ledger
      expect(share_transaction.client_account.ledger.closing_balance).to eq(0)
      expect(nepse_ledger.closing_balance).to eq(15024)
      closeout_ledger = Ledger.find_by(name: "Close Out")
      expect(closeout_ledger.present?).to be_truthy
      expect(closeout_ledger.closing_balance).to eq(-15024)
      expect(closeout_ledger.particulars.count).to eq(1)
      expect(share_transaction.reload.closeout_settled).to_not be_truthy
    end

  end


end