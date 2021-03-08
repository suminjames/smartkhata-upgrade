require 'rails_helper'

RSpec.describe GenerateBillsService  do
  let(:nepse_settlement) {create(:nepse_sale_settlement)}
  let(:sales_share_transaction) {create(:sales_share_transaction_processed, settlement_id: nepse_settlement.settlement_id)}
  let(:sales_share_transaction_with_closeout) {create(:sales_share_transaction_processed_with_closeout, settlement_id: nepse_settlement.settlement_id)}
  let(:sales_share_transaction_with_full_closeout) {create(:sales_share_transaction_processed_with_full_closeout, settlement_id: nepse_settlement.settlement_id)}
  # let(:nepse_ledger){ Ledger.find_or_create_by!(name: "Nepse Sales")}
  let(:sales_commission_ledger) { create(:ledger, name: 'Sales Commission') }
  let(:nepse_ledger) { create(:ledger, name: 'Nepse Sales') }
  let(:tds_ledger) { create(:ledger, name: 'TDS') }
  let(:transfer_ledger) { create(:ledger, name: 'DP Fee/ Transfer') }
  let(:rounding_off_ledger) { create(:ledger, name: 'Rounding Off Difference') }
  let(:close_out_ledger) { create(:ledger, name: 'Close Out') }

  let(:current_user){create(:user)}
  let(:branch) {create(:branch)}

  before do
    UserSession.user = create(:user)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374
    @fy_code = 7374
    allow_any_instance_of(GenerateBillsService).to receive(:broker_commission_rate).and_return(0.8)

  end

  context "when bills are generated based on settlement id" do
    context "automatic settlement by system" do
      it 'should generate the bill for normal transaction' do

        sales_share_transaction
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(Voucher.count).to eq 1
        expect(sales_share_transaction.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-115130.67)
        expect(sales_share_transaction.client_account.ledger.particulars.count).to eq(1)
      end

      it 'should generate the bill for partial closeout and ledger entry' do
        sales_share_transaction_with_closeout
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        close_out_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq 109106.67
        expect(bill.closeout_charge).to eq 15024
        expect(Voucher.count).to eq 2
        expect(sales_share_transaction_with_closeout.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-100106.67)
        expect(sales_share_transaction_with_closeout.client_account.ledger.particulars.count).to eq(2)
        expect(sales_share_transaction_with_closeout.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance((@fy_code).to_f)).to eq(0)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(100564.8)
      end

      it 'should not generate the bill for full closeout and ledger entry' do
        sales_share_transaction_with_full_closeout
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        close_out_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq -14841.33
        expect(bill.closeout_charge).to eq 138972


        expect(Voucher.count).to eq 2
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.closing_balance(@fy_code).to_f).to eq(23841.33)
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.particulars.count).to eq(2)
        expect(sales_share_transaction_with_full_closeout.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(0)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(-23383.2)
      end
    end

    context "automatic settlement by system" do
      it 'should generate the bill for normal transaction' do
        sales_share_transaction
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(Voucher.count).to eq 1
        expect(sales_share_transaction.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-115130.67)
        expect(sales_share_transaction.client_account.ledger.particulars.count).to eq(1)
      end

      it 'should generate the bill for partial closeout and ledger entry' do
        sales_share_transaction_with_closeout
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        close_out_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq  109106.67
        expect(bill.closeout_charge).to eq 15024
        expect(Voucher.count).to eq 2
        expect(sales_share_transaction_with_closeout.client_account.ledger.closing_balance(7374).to_f).to eq(-100106.67)
        expect(sales_share_transaction_with_closeout.client_account.ledger.particulars.count).to eq(2)
        expect(sales_share_transaction_with_closeout.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(0)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(100564.8)
      end

      it 'should not generate the bill for full closeout and ledger entry' do
        sales_share_transaction_with_full_closeout
        sales_share_transaction
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: true), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq   -14841.33
        expect(bill.closeout_charge).to eq 138972


        expect(Voucher.count).to eq 2
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.closing_balance(@fy_code).to_f).to eq(23841.33)
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.particulars.count).to eq(2)
        expect(sales_share_transaction_with_full_closeout.reload.closeout_settled).to be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(0)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(-23383.2)
      end
    end
    context "manual interventions for closeouts" do
      it 'should generate the bill for normal transaction' do
        sales_share_transaction
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: false), current_user: current_user, branch: branch)
        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(Voucher.count).to eq 1
        expect(sales_share_transaction.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-115130.67)
        expect(sales_share_transaction.client_account.ledger.particulars.count).to eq(1)
      end

      it 'should generate the bill for partial closeout and ledger entry' do
        sales_share_transaction_with_closeout
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        close_out_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: false), current_user: current_user, branch: branch)

        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq  124130.67
        expect(bill.closeout_charge).to eq 0
        expect(Voucher.count).to eq 1
        expect(sales_share_transaction_with_closeout.client_account.ledger.closing_balance(@fy_code)).to eq(-115130.67)
        expect(sales_share_transaction_with_closeout.client_account.ledger.particulars.count).to eq(1)
        expect(sales_share_transaction_with_closeout.closeout_settled).to_not be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(15024)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(100564.8)
      end

      it 'should generate the bill for full closeout and ledger entry' do
        sales_share_transaction_with_full_closeout
        sales_commission_ledger
        nepse_ledger
        tds_ledger
        transfer_ledger
        rounding_off_ledger
        close_out_ledger
        generate_bill_service = GenerateBillsService.new(nepse_settlement: nepse_settlement, current_tenant: Tenant.new(closeout_settlement_automatic: false),  current_user: current_user, branch: branch)

        generate_bill_service.process
        expect(Bill.count).to eq 1
        bill = Bill.first
        expect(bill.purchase?).to be_truthy
        expect(bill.net_amount.to_f).to eq  124130.67
        expect(bill.closeout_charge).to eq 0


        expect(Voucher.count).to eq 1
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.closing_balance(@fy_code).to_f).to eq(-115130.67)
        expect(sales_share_transaction_with_full_closeout.client_account.ledger.particulars.count).to eq(1)
        expect(sales_share_transaction_with_full_closeout.closeout_settled).to_not be_truthy
        closeout_ledger = Ledger.find_by(name: "Close Out")
        expect(closeout_ledger.present?).to be_truthy
        expect(closeout_ledger.closing_balance(@fy_code)).to eq(138972)
        expect(nepse_ledger.closing_balance(@fy_code).to_f).to eq(-23383.2)
      end
    end
  end


  context "manual interventions to create missing bills" do

    it 'should validate if bill is already generated' do
      sales_share_transaction.update_column(:bill_id, 1)
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new, contract_numbers: [sales_share_transaction.contract_no], manual: true, skip_voucher: true,  current_user: current_user, branch: branch)
      expect { generate_bill_service.process }.to raise_error(NotImplementedError)
    end

    it 'should validate share_transactions presence' do
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new, manual: true, skip_voucher: true)
      expect { generate_bill_service.process }.to raise_error(NotImplementedError)
    end

    it 'should validate settlement id  presence for share transactions' do
      sales_share_transaction.update_column(:settlement_id, nil)
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new,contract_numbers: [sales_share_transaction.contract_no], manual: true, skip_voucher: true,  current_user: current_user, branch: branch)
      expect { generate_bill_service.process }.to raise_error(NotImplementedError)
    end

    it 'should validate the share transactions have same settlement id' do
      # invalid case
      sales_share_transaction
      new_sales_share_transaction = create(:sales_share_transaction_processed, settlement_id: '12444', contract_no: 4567, isin_info: sales_share_transaction.isin_info)
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new,contract_numbers: [sales_share_transaction.contract_no, 4567], manual: true, skip_voucher: true, current_user: current_user, branch: branch )
      expect { generate_bill_service.process }.to raise_error(NotImplementedError)

      # valid case
      new_sales_share_transaction = create(:sales_share_transaction_processed, settlement_id: sales_share_transaction.settlement_id, contract_no: 14567, isin_info: sales_share_transaction.isin_info, client_account: sales_share_transaction.client_account)
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new,contract_numbers: [sales_share_transaction.contract_no, 14567], manual: true, skip_voucher: true, current_user: current_user, branch: branch)
      generate_bill_service.process
      expect(Bill.count).to eq 1
    end

    it 'should generate the bill for transaction' do
      sales_share_transaction
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new, contract_numbers: [sales_share_transaction.contract_no], manual: true, skip_voucher: true, current_user: current_user, branch: branch)
      generate_bill_service.process
      expect(Bill.count).to eq 1
      bill = Bill.first
      expect(bill.purchase?).to be_truthy
      expect(Voucher.count).to eq 0
      expect(sales_share_transaction.client_account.ledger.closing_balance(@fy_code)).to eq(0)
      expect(sales_share_transaction.client_account.ledger.particulars.count).to eq(0)
    end

    it 'should generate the bill and voucher for normal transaction' do
      sales_share_transaction
      generate_bill_service = GenerateBillsService.new(current_tenant: Tenant.new, contract_numbers: [sales_share_transaction.contract_no], manual: true, current_user: current_user, branch: branch)
      generate_bill_service.process
      expect(Bill.count).to eq 1
      bill = Bill.first
      expect(bill.purchase?).to be_truthy
      expect(Voucher.count).to eq 1
      expect(sales_share_transaction.client_account.ledger.closing_balance(@fy_code)).to eq(-115130.6726)
      expect(sales_share_transaction.client_account.ledger.particulars.count).to eq(1)
    end
  end
end
