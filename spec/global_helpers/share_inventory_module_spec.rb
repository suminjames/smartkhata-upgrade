require 'rails_helper'

RSpec.describe ShareInventoryModule, type: :helper do
  include_context 'session_setup'
  let(:dummy_class) { Class.new { extend ShareInventoryModule } }

  describe '.update_share_inventory' do
    let(:client_account) {create(:client_account)}
    let(:isin_info) {create(:isin_info)}
    let!(:share_transaction) {create(:share_transaction, client_account_id: client_account.id, isin_info_id: isin_info.id, transaction_type: 0, quantity: 2000)}

    context 'when deal cancelled' do
      context 'and is incremented' do
        it 'should update share inventory' do
          dummy_class.update_share_inventory(share_transaction.client_account_id, share_transaction.isin_info_id, share_transaction.quantity, true, true)
          expect(ShareInventory.first.total_in).to eq(-2000)
          expect(ShareInventory.first.floorsheet_blnc).to eq(-2000)
        end
      end

      context 'and isnot incremented' do
        it 'should update share inventory' do
          dummy_class.update_share_inventory(share_transaction.client_account_id, share_transaction.isin_info_id, share_transaction.quantity, false, true)
          expect(ShareInventory.first.total_out).to eq(-2000)
          expect(ShareInventory.first.floorsheet_blnc).to eq(2000)
        end
      end
    end

    context 'when deal not cancelled' do
      context 'and is incremented' do
        it 'should update share inventory' do
          dummy_class.update_share_inventory(share_transaction.client_account_id, share_transaction.isin_info_id, share_transaction.quantity, true, false)
          expect(ShareInventory.first.total_in).to eq(2000)
          expect(ShareInventory.first.floorsheet_blnc).to eq(2000)
        end
      end

      context 'and isnot incremented' do
        it 'should update share inventory' do
          dummy_class.update_share_inventory(share_transaction.client_account_id, share_transaction.isin_info_id, share_transaction.quantity, false, false)
          expect(ShareInventory.first.total_out).to eq(2000)
          expect(ShareInventory.first.floorsheet_blnc).to eq(-2000)
        end
      end
    end
  end
end