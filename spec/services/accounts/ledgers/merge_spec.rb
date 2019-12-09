require 'rails_helper'
describe Accounts::Ledgers::Merge do
  include_context 'session_setup'
  let(:current_user) {@user}
  before do
    @ledger_to_merge_to = create(:ledger)
    @ledger_to_merge_from = create(:ledger)
    @new_branch = create(:branch)
    @other_fy_code = 7172

    # overall & @other_fy_code
    @ledger_balance_org1 = create(:ledger_balance_org, opening_balance: 3000, fy_code: @other_fy_code, ledger_id: @ledger_to_merge_to.id)
    @ledger_balance_org2 = create(:ledger_balance_org, opening_balance: 2000, fy_code: @other_fy_code, ledger_id: @ledger_to_merge_from.id)

    # specific branch & @other_fy_code
    @ledger_balance1_branch2 = create(:ledger_balance_org, opening_balance: 3000, fy_code: @other_fy_code, ledger_id: @ledger_to_merge_to.id, branch_id: @new_branch.id)
    @ledger_balance2_branch2 = create(:ledger_balance_org, opening_balance: 1000, fy_code: @other_fy_code, ledger_id: @ledger_to_merge_from.id, branch_id: @new_branch.id)

    # particulars for @other_fy_code & @branch
    @particular1_branch1 = create(:particular, ledger_id: @ledger_to_merge_to.id, branch_id: @branch.id, amount: 1000, fy_code: @other_fy_code)
    @particular2_branch1 = create(:particular, ledger_id: @ledger_to_merge_from.id, branch_id: @branch.id, amount: 2000, fy_code: @other_fy_code)

    # particulars for @other_fy_code & @new_branch
    @particular1_branch2 = create(:particular, ledger_id: @ledger_to_merge_to.id, branch_id: @new_branch.id, amount: 6000, fy_code: @other_fy_code)
    @particular2_branch2 = create(:particular, ledger_id: @ledger_to_merge_from.id, branch_id: @new_branch.id, amount: 3000, fy_code: @other_fy_code)

  end

  subject { Accounts::Ledgers::Merge.new(@ledger_to_merge_to.id, @ledger_to_merge_from.id, current_user) }

  describe '.fix_opening_balances' do
    it 'merges opening balances' do
       subject.fix_opening_balances
      expect(@ledger_balance_org1.reload.opening_balance).to eq(5000)
      expect(@ledger_balance1_branch2.reload.opening_balance).to eq(4000)
    end
  end

  describe '.fix_ledger_dailies_and_closing_balances' do
    before do
      subject.fix_opening_balances
      subject.fix_ledger_dailies_and_closing_balances
    end

    it 'fixes ledger dailies and closing balance for branch' do
      expect(@ledger_to_merge_to.reload.closing_balance(@other_fy_code, @new_branch.id)).to eq(13000)
      expect(@ledger_to_merge_from.reload.ledger_balances.size).to eq(0)
    end

    it 'fixes ledger dailies and closing balance for org' do
      # sum of all
      expect(@ledger_to_merge_to.reload.closing_balance(@other_fy_code, 0)).to eq(17000)
      expect(@ledger_to_merge_from.reload.ledger_balances.size).to eq(0)
      expect(@ledger_to_merge_from.reload.ledger_dailies.size).to eq(0)
    end

  end

  describe '.merge_client_accounts' do
    before do
      @client_account = create(:client_account)
      @ledger_to_merge_from.client_account = @client_account
      @ledger_to_merge_from.save!
    end

    context 'when client account to persist is not present' do
      it 'assigns other client account' do
        ledger_to_merge_to = subject.merge_client_accounts
        expect(ledger_to_merge_to.client_account).to eq(@client_account)
        expect(ledger_to_merge_to.client_code).to eq(@client_account.nepse_code)
      end
    end

    context 'when client account to persist is present' do
      before do
        @client_account_persist = create(:client_account)
        @ledger_to_merge_to.client_account = @client_account_persist
        @ledger_to_merge_to.save!
      end

      it 'squishes nepse code and name' do
        @client_account_persist.update_attributes(nepse_code: "Nepse-3\t", name: 'random      nep')
        subject.merge_client_accounts
        expect(@client_account_persist.reload.nepse_code).to eq('NEPSE-3')
        expect(@client_account_persist.reload.name).to eq('random nep')
      end

      context 'when nepse code is present on both' do
        it 'makes no changes' do
          prev_nepse_code = @client_account_persist.nepse_code
          subject.merge_client_accounts
          expect(@client_account_persist.reload.nepse_code).to eq(prev_nepse_code)
        end
      end
      context 'when nepse code is not present on persisting client account' do
        it 'takes  nepse code' do
          nepse_code = @client_account.nepse_code
          @client_account_persist.update_attributes(nepse_code: nil)
          subject.merge_client_accounts
          expect(@client_account_persist.reload.nepse_code).to eq(nepse_code)
        end
      end

      context 'when email and phone number is present on persisting client account' do
        it 'makes no change' do

        end
      end
    end


  end

  describe '.call' do
    it 'merges ledgers' do
      subject.call
      expect(Ledger.where(id: @ledger_to_merge_from).size).to eq(0)
      expect(@ledger_to_merge_to.reload.closing_balance(@other_fy_code)).to eq(17000)
      expect(@ledger_to_merge_to.reload.particulars.size).to eq(4)
    end
  end
end