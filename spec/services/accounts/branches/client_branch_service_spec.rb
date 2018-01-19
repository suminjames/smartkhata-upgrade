# require 'rails_helper'
#
# describe Accounts::Branches::ClientBranchService do
#   include_context 'session_setup'
#
#   before do
#     @client_account = create(:client_account, name: "John", branch_id: 1)
#     @other_client_account = create(:client_account, name: "preeti", branch_id: 1)
#     @ledger = create(:ledger, client_account_id: @client_account.id, branch_id: 1)
#     @other_ledger = create(:ledger, client_account_id: @other_client_account.id, branch_id: 1)
#     @voucher = create(:voucher, branch_id: 1, fy_code: 7475)
#     @particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-9-16', ledger_id: @ledger.id, branch_id: 1)
#     @other_particular = create(:particular, voucher_id: @voucher.id, transaction_date: '2017-10-16', ledger_id: @other_ledger.id, branch_id: 1)
#     @bill = create(:bill, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
#     @settlement = create(:settlement, client_account_id: @client_account.id, date: '2017-9-16', branch_id: 1, fy_code: 7475)
#     @client_account.bills << @bill
#     subject {Accounts::Branches::ClientBranchService.new}
#   end
#   describe 'move transactions' do
#     it 'should move transactions' do
#       UserSession.selected_fy_code = 7475
#       subject.move_transactions(@client_account, 2, nil)
#       expect(Bill.unscoped.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
#       expect(Settlement.where(client_account_id: @client_account.id).first.branch_id).to eq(2)
#       expect(@client_account.ledger.particulars.first.branch_id).to eq(2)
#       expect(@client_account.ledger.particulars.first.voucher.branch_id).to eq(1)
#     end
#   end
#
#   describe 'patch client branch' do
#     it 'should patch clients branch' do
#       allow(subject).to receive(:move_transactions).with(@client_account, 2).and_return([[@ledger.id], [7475]])
#     end
#   end
# end