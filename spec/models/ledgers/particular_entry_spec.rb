require 'rails_helper'

RSpec.describe  Ledgers::ParticularEntry do
  include_context 'session_setup'

  let!(:ledger) {create(:ledger)}

  describe '.calculate_balances' do
    particular_entry = Ledgers::ParticularEntry.new


    context 'when accounting date is before date' do
      let!(:ledger_daily_org_subject) {create(:ledger_daily, ledger: ledger, opening_balance: 0, closing_balance: 6000, dr_amount: 6000, branch_id: nil, fy_code: 7475, date: '2017-01-02')}
      let!(:ledger_daily_org_future) {create(:ledger_daily, ledger: ledger, opening_balance: 6000, closing_balance: 7000, dr_amount: 1000, branch_id: nil, fy_code: 7475, date: '2017-02-03')}
      let!(:ledger_daily_subject) {create(:ledger_daily, ledger: ledger, opening_balance: 0, closing_balance: 5000,dr_amount: 5000, branch_id: 1, fy_code: 7475, date: '2017-01-02')}
      let!(:ledger_daily_future) {create(:ledger_daily, ledger: ledger, opening_balance: 5000, closing_balance: 6000, dr_amount: 1000, branch_id: 1, fy_code: 7475, date: '2017-02-03')}

      # cant assign closing balance here
      let!(:ledger_balance_org) {create(:ledger_balance, ledger: ledger, opening_balance: 0, branch_id: nil, fy_code: 7475)}
      let!(:ledger_balance) {create(:ledger_balance, ledger: ledger, opening_balance: 0, branch_id: 1, fy_code: 7475)}

      context 'and debit' do
        before do
          ledger_balance.update_attributes(closing_balance: 6000, dr_amount: 6000)
          ledger_balance_org.update_attributes(closing_balance: 7000, dr_amount: 7000)
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-01-02'.to_date, true, 4000, 7475, 1)
        end

        it "adds dr_amount and increments closing balance for ledger dailies for that day" do
          # expect changes for ledger_daily_subject for the date
          expect(ledger_daily_subject.reload.dr_amount).to eq(9000)
          expect(ledger_daily_subject.reload.cr_amount).to eq(0)
          expect(ledger_daily_subject.reload.closing_balance).to eq(9000)
          expect(ledger_daily_subject.reload.opening_balance).to eq(0)

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
          ledger_balance.update_attributes(closing_balance: 6000, dr_amount: 6000)
          ledger_balance_org.update_attributes(closing_balance: 7000, dr_amount: 7000)
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-01-02'.to_date, false, 4000, 7475, 1)
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
      let!(:ledger_daily_org_previous) {create(:ledger_daily, ledger: ledger, opening_balance: 6000, closing_balance: 7000, dr_amount: 1000, branch_id: nil, fy_code: 7475, date: '2017-02-03')}
      let!(:ledger_daily_previous) {create(:ledger_daily, ledger: ledger, opening_balance: 5000, closing_balance: 6000, dr_amount: 1000, branch_id: 1, fy_code: 7475, date: '2017-02-03')}

      # cant assign closing balance here
      let!(:ledger_balance_org) {create(:ledger_balance, ledger: ledger, opening_balance: 7000, branch_id: nil, fy_code: 7475)}
      let!(:ledger_balance) {create(:ledger_balance, ledger: ledger, opening_balance: 6000, branch_id: 1, fy_code: 7475)}

      context 'and debit' do
        before do
          ledger_balance.update_attributes(closing_balance: 11000, dr_amount: 5000)
          ledger_balance_org.update_attributes(closing_balance: 13000, dr_amount: 6000)
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-03-08'.to_date, true, 4000, 7475, 1)
        end

        it "adds dr_amount and increments closing balance for ledger dailies for that day" do
          # creates ledger daily with date equal to accounting date if not present
          ledger_daily = LedgerDaily.third
          ledger_daily_org = LedgerDaily.last

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
          expect(ledger_balance.reload.dr_amount).to eq(9000)
          expect(ledger_balance.reload.cr_amount).to eq(0)
          expect(ledger_balance.reload.closing_balance).to eq(15000)

          expect(ledger_balance_org.reload.dr_amount).to eq(10000)
          expect(ledger_balance_org.reload.cr_amount).to eq(0)
          expect(ledger_balance_org.reload.closing_balance).to eq(17000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([10000, 11000])
        end
      end
      context 'and credit' do
        before do
          ledger_balance.update_attributes(closing_balance: 11000, dr_amount: 5000)
          ledger_balance_org.update_attributes(closing_balance: 13000, dr_amount: 6000)
          @calculate_balances = particular_entry.calculate_balances(ledger, '2017-03-08'.to_date, false, 4000, 7475, 1)
        end

        it "adds cr_amount and decrements closing balance for ledger dailies for that day" do
          # creates ledger daily with date equal to accounting date if not present
          ledger_daily = LedgerDaily.third
          ledger_daily_org = LedgerDaily.last

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
          expect(ledger_balance.reload.dr_amount).to eq(5000)
          expect(ledger_balance.reload.cr_amount).to eq(4000)
          expect(ledger_balance.reload.closing_balance).to eq(7000)

          expect(ledger_balance_org.reload.dr_amount).to eq(6000)
          expect(ledger_balance_org.reload.cr_amount).to eq(4000)
          expect(ledger_balance_org.reload.closing_balance).to eq(9000)
        end

        it 'returns closing balances' do
          expect(@calculate_balances).to eq([2000, 3000])
        end
      end
    end
  end
end