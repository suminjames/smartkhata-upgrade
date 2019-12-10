require 'rails_helper'

RSpec.describe  Ledgers::ParticularEntry do
  include Accounts::Ledgers
  include_context 'session_setup'

  let(:current_user){@user}
  let!(:ledger) {create(:ledger, current_user_id: current_user.id)}
  let(:branch1) { Branch.first }
  let(:branch2) { create(:branch) }
  let(:particular_entry){Ledgers::ParticularEntry.new(current_user.id)}
  let!(:before_particular_branch_1) { create(:particular, ledger_id: ledger.id, branch_id: branch1.id, amount: 5000, transaction_date: '2017-01-02', fy_code: 7475) }
  let!(:before_particular_branch_2) { create(:particular, ledger_id: ledger.id, branch_id: branch2.id, amount: 1000, transaction_date: '2017-01-02', fy_code: 7475) }
  let!(:after_particular_branch_1) { create(:particular, ledger_id: ledger.id, branch_id: branch1.id, amount: 1000, transaction_date: '2017-02-03', fy_code: 7475) }

  let(:ledger_daily_org_subject) { LedgerDaily.unscoped.where(ledger: ledger, fy_code: 7475, branch_id: nil, date: '2017-01-02').first }
  let(:ledger_daily_org_future) { LedgerDaily.unscoped.where(ledger: ledger, fy_code: 7475, branch_id: nil, date: '2017-02-03').first }
  let(:ledger_daily_subject) { LedgerDaily.unscoped.where(ledger: ledger, fy_code: 7475, branch_id: branch1.id, date: '2017-01-02').first }
  let(:ledger_daily_future) { LedgerDaily.unscoped.where(ledger: ledger, fy_code: 7475, branch_id: branch1.id, date: '2017-02-03').first }

  let(:ledger_balance_org) { LedgerBalance.unscoped.by_fy_code_org(7475).where(ledger_id: ledger.id).first }
  let(:ledger_balance) { LedgerBalance.unscoped.by_branch_fy_code(branch1.id, 7475).where(ledger_id: ledger.id).first }

  before do
    travel_to Time.local(2017, 02, 01)
    Branch.pluck(:id).each do |branch_id|
      Accounts::Ledgers::PopulateLedgerDailiesService.new.process(ledger.id, false, branch_id, 7475, current_user.id)
      Accounts::Ledgers::ClosingBalanceService.new.process(ledger.id, false, branch_id, 7475, current_user.id)
    end
    expect(ledger_balance.reload.dr_amount).to eq(6000)
    expect(ledger_balance.reload.cr_amount).to eq(0)
    expect(ledger_balance.reload.closing_balance).to eq(6000)
    # 6000 + 1000 + 4000(new)
    expect(ledger_balance_org.reload.dr_amount).to eq(7000)
    expect(ledger_balance_org.reload.cr_amount).to eq(0)
    expect(ledger_balance_org.reload.closing_balance).to eq(7000)
    #
  end

  describe '.calculate_balances' do

    context 'when accounting date is before date' do

      context 'and debit' do

        before do

          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-01-02'.to_date, true, 4000, 7475, branch1.id, current_user.id)
          ledger_daily_subject
          ledger_daily_future
          ledger_daily_org_subject
          ledger_daily_org_future
        end

        it "adds dr_amount and increments closing balance for ledger dailies for that day" do
          # expect changes for ledger_daily_subject for the date
          expect(ledger_daily_subject.dr_amount).to eq(9000)
          expect(ledger_daily_subject.cr_amount).to eq(0)
          expect(ledger_daily_subject.closing_balance).to eq(9000)
          expect(ledger_daily_subject.opening_balance).to eq(0)

          # expect changes for ledger_daily_org_subject for the date
          expect(ledger_daily_org_subject.reload.dr_amount).to eq(10000)
          expect(ledger_daily_org_subject.reload.cr_amount).to eq(0)
          expect(ledger_daily_org_subject.reload.closing_balance).to eq(10000)
          expect(ledger_daily_org_subject.reload.opening_balance).to eq(0)
        end

        it "adds dr_amount and increments closing balance for ledger balances for that day" do
          # expect changes for ledger balance
          # 5000 + 1000 + 4000(new)
          expect(ledger_balance.reload.dr_amount).to eq(10000)
          expect(ledger_balance.reload.cr_amount).to eq(0)
          expect(ledger_balance.reload.closing_balance).to eq(10000)
          # 6000 + 1000 + 4000(new)
          expect(ledger_balance_org.reload.dr_amount).to eq(11000)
          expect(ledger_balance_org.reload.cr_amount).to eq(0)
          expect(ledger_balance_org.reload.closing_balance).to eq(11000)
        end

        it 'carries the dr_amount, opening balance and closing balance to the future dates' do
          # ledger dailies after transaction also get modified

          expect(ledger_daily_future.reload.closing_balance).to eq(10000)
          expect(ledger_daily_org_future.reload.closing_balance).to eq(11000)
          expect(ledger_daily_future.reload.opening_balance).to eq(9000)
          expect(ledger_daily_org_future.reload.opening_balance).to eq(10000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([9000, 10000])
        end
      end

      context 'and credit' do
        before do
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-01-02'.to_date, false, 4000, 7475, branch1.id, current_user.id)
        end

        it "adds cr_amount and decrements closing balance for ledger dailies for that day" do
          # expect changes for ledger_daily_subject for the date
          expect(ledger_daily_subject.reload.dr_amount).to eq(5000)
          expect(ledger_daily_subject.reload.cr_amount).to eq(4000)
          expect(ledger_daily_subject.reload.closing_balance).to eq(1000)
          expect(ledger_daily_subject.reload.opening_balance).to eq(0)

          # expect changes for ledger_daily_org_subject for the date
          expect(ledger_daily_org_subject.reload.dr_amount).to eq(6000)
          expect(ledger_daily_org_subject.reload.cr_amount).to eq(4000)
          expect(ledger_daily_org_subject.reload.closing_balance).to eq(2000)
          expect(ledger_daily_org_subject.reload.opening_balance).to eq(0)
        end

        it "adds cr_amount and decrements  closing balance for ledger balances for that day" do
          # expect changes for ledger balance
          expect(ledger_balance.reload.dr_amount).to eq(6000)
          expect(ledger_balance.reload.cr_amount).to eq(4000)
          expect(ledger_balance.reload.closing_balance).to eq(2000)

          expect(ledger_balance_org.reload.dr_amount).to eq(7000)
          expect(ledger_balance_org.reload.cr_amount).to eq(4000)
          expect(ledger_balance_org.reload.closing_balance).to eq(3000)
        end

        it 'carries the cr_amount, opening balance and closing balance to the future dates' do
          # ledger dailies after transaction also get modified
          expect(ledger_daily_future.reload.closing_balance).to eq(2000)
          expect(ledger_daily_org_future.reload.closing_balance).to eq(3000)
          expect(ledger_daily_future.reload.opening_balance).to eq(1000)
          expect(ledger_daily_org_future.reload.opening_balance).to eq(2000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([1000, 2000])
        end
      end
    end
    context 'when accounting date is after date' do
      context 'and debit' do
        before do
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-03-08'.to_date, true, 4000, 7475, branch1.id, current_user.id)
        end

        it "creates new ledger dailies for that day" do
          ledger_daily = LedgerDaily.where(branch_id: branch1.id, date: '2017-03-08').first
          ledger_daily_org = LedgerDaily.where(branch_id: nil, date: '2017-03-08').first
          expect(ledger_daily.reload.dr_amount).to eq(4000)
          expect(ledger_daily.reload.cr_amount).to eq(0)
          expect(ledger_daily.reload.closing_balance).to eq(10000)
          expect(ledger_daily.reload.opening_balance).to eq(6000)

          expect(ledger_daily_org.reload.dr_amount).to eq(4000)
          expect(ledger_daily_org.reload.cr_amount).to eq(0)
          expect(ledger_daily_org.reload.closing_balance).to eq(11000)
          expect(ledger_daily_org.reload.opening_balance).to eq(7000)
        end

        it "adds dr_amount and increments closing balance for ledger balances for that day" do
          # expect changes for ledger balance
          expect(ledger_balance.reload.dr_amount).to eq(10000)
          expect(ledger_balance.reload.cr_amount).to eq(0)
          expect(ledger_balance.reload.closing_balance).to eq(10000)

          expect(ledger_balance_org.reload.dr_amount).to eq(11000)
          expect(ledger_balance_org.reload.cr_amount).to eq(0)
          expect(ledger_balance_org.reload.closing_balance).to eq(11000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([10000, 11000])
        end
      end
      context 'and credit' do
        before do
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-03-08'.to_date, false, 4000, 7475, branch1.id,current_user.id)
        end

        it "creates new ledger dailies for that day" do
          ledger_daily = LedgerDaily.where(branch_id: branch1.id).last
          ledger_daily_org = LedgerDaily.where(branch_id: nil).last

          expect(ledger_daily.reload.dr_amount).to eq(0)
          expect(ledger_daily.reload.cr_amount).to eq(4000)
          expect(ledger_daily.reload.closing_balance).to eq(2000)
          expect(ledger_daily.reload.opening_balance).to eq(6000)

          expect(ledger_daily_org.reload.dr_amount).to eq(0)
          expect(ledger_daily_org.reload.cr_amount).to eq(4000)
          expect(ledger_daily_org.reload.closing_balance).to eq(3000)
          expect(ledger_daily_org.reload.opening_balance).to eq(7000)
        end

        it "adds cr_amount and decrements closing balance for ledger balances for that day" do
          # expect changes for ledger balance
          expect(ledger_balance.reload.dr_amount).to eq(6000)
          expect(ledger_balance.reload.cr_amount).to eq(4000)
          expect(ledger_balance.reload.closing_balance).to eq(2000)

          expect(ledger_balance_org.reload.dr_amount).to eq(7000)
          expect(ledger_balance_org.reload.cr_amount).to eq(4000)
          expect(ledger_balance_org.reload.closing_balance).to eq(3000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([2000, 3000])
        end
      end
    end
  end

  after do
    travel_back
  end
end