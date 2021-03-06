require 'rails_helper'

RSpec.describe ChequeEntries::Activity do
  include_context 'session_setup'
  include ActiveSupport::Testing::TimeHelpers

  let(:branch){ create(:branch) }
  let(:bank){create(:bank)}
  let(:bank_account) { create(:bank_account, bank: bank, branch: branch) }
  let(:additional_bank) { create(:bank) }
  let(:cheque_entry) { create(:cheque_entry, branch_id: 1, bank: bank, bank_account: bank_account, additional_bank: additional_bank, branch: branch) }
  subject { ChequeEntries::Activity.new(cheque_entry, 'trishakti', User.first.id, branch.id, 7576) }

  before do
    travel_to "2019-01-01".to_date
    allow(DateTime).to receive(:now).and_return Date.today
  end

  describe '.process' do
    context 'when invalid fy_code' do
      it 'adds error' do
        allow(subject).to receive(:valid_for_the_fiscal_year?).and_return(false)
        subject.process
        expect(subject.error_message).to eq('Please select the current fiscal year')
      end
    end

    context 'when activity cant be done' do
      it 'returns nil' do
        allow(subject).to receive(:valid_for_the_fiscal_year?).and_return(true)
        expect(subject.process).to eq(nil)
        expect(subject.error_message).to eq(nil)
      end
    end

    context 'when invalid branch' do
      it 'adds error' do
        allow(subject).to receive(:valid_for_the_fiscal_year?).and_return(true)
        allow(subject).to receive(:can_activity_be_done?).and_return(true)
        allow(subject).to receive(:valid_branch?).and_return(false)
        subject.process
        expect(subject.error_message).to eq('Please select the correct branch')
      end
    end

    context 'when perform action' do
      it 'raises error' do
        allow(subject).to receive(:valid_for_the_fiscal_year?).and_return(true)
        allow(subject).to receive(:can_activity_be_done?).and_return(true)
        allow(subject).to receive(:valid_branch?).and_return(true)
        expect{subject.process}.to raise_error(NotImplementedError)
      end
    end
  end

  describe '.perform_action' do
    it 'raises error' do
      expect{subject.perform_action}.to raise_error(NotImplementedError)
    end
  end

  describe '.can_activity_be_done?' do
    it 'returns false' do
      expect(subject.can_activity_be_done?).to eq(false)
    end
  end

  describe '.valid_branch?' do
    context  'when branch matched to user selected branch' do
      it 'returns true' do
        expect(subject.valid_branch?).to eq(true)
      end
    end

    context 'when branch unmatched to user selected branch' do
      it 'returns false' do
        subject.selected_branch_id = 2
        expect(subject.valid_branch?).to eq(false)
      end
    end
  end

  describe '.valid_for_the_fiscal_year?' do
    context 'when fy_code matched to user selected fy_code' do
      it 'returns true' do
        expect(subject.valid_for_the_fiscal_year?).to eq(true)
      end
    end

    context 'when fy_code not matched to user selected fy_code' do
      it 'returns false' do
        subject.selected_fy_code = 7374
        expect(subject.valid_for_the_fiscal_year?).to eq(false)
      end
    end
  end

  describe '.set_error' do
    it 'returns error message' do
      error_message = 'This is error message'
      expect(subject.set_error(error_message)).to eq('This is error message')
    end
  end

  describe '.get_bank_name_and_date' do
    context 'when additional bank id present' do
      context 'and cheque date not present' do
        it 'returns array' do
          bank
          cheque_entry.additional_bank_id = bank.id
          cheque_entry.cheque_date = nil
          # expect(subject.get_bank_name_and_date).to eq([bank, 'trishakti', DateTime.now])
          result = subject.get_bank_name_and_date
          expect(result[0..1]).to eq([bank, 'trishakti'])
          expect(result[2].to_date).to eq(Date.today)
        end
      end
      context'and cheque date present' do
        it 'returns array' do
          bank
          cheque_entry.additional_bank_id = bank.id
          cheque_entry.cheque_date = '2016-07-04'
          expect(subject.get_bank_name_and_date).to eq([bank, 'trishakti', '2016-07-04'.to_date])
        end
      end
    end

    context 'when additional bank id not present' do
      context 'and cheque date not present' do
        context 'and beneficiary name present' do
          it 'returns array' do
            bank
            bank_account
            cheque_entry.bank_account_id = bank_account.id
            cheque_entry.additional_bank_id = nil
            cheque_entry.cheque_date = nil
            cheque_entry.beneficiary_name = 'random'
            # expect(subject.get_bank_name_and_date).to eq([bank, 'random', DateTime.now])
            result = subject.get_bank_name_and_date
            expect(result[0..1]).to eq([bank, 'random'])
            expect(result[2].to_date).to eq(Date.today)
          end
        end
        context 'and beneficiary name not present' do
          it 'returns array' do
            bank
            bank_account
            cheque_entry
            cheque_entry.bank_account_id = bank_account.id
            cheque_entry.additional_bank_id = nil
            cheque_entry.cheque_date = nil
            cheque_entry.beneficiary_name = nil
            # expect(subject.get_bank_name_and_date).to eq([bank, 'Internal Ledger', DateTime.now])
            result = subject.get_bank_name_and_date
            expect(result[0..1]).to eq([bank, 'Internal Ledger'])
            expect(result[2].to_date).to eq(Date.today)
          end
        end
      end

      context 'and cheque date present' do
        context 'and beneficiary name present' do
          it 'returns array' do
            bank
            bank_account
            cheque_entry.bank_account_id = bank_account.id
            cheque_entry.additional_bank_id = nil
            cheque_entry.cheque_date = '2016-07-04'
            cheque_entry.beneficiary_name = 'random'
            expect(subject.get_bank_name_and_date).to eq([bank, 'random', '2016-07-04'.to_date])
          end
        end
        context 'and beneficiary name not present' do
          it 'returns array' do
            bank
            bank_account
            cheque_entry.bank_account_id = bank_account.id
            cheque_entry.additional_bank_id = nil
            cheque_entry.cheque_date = '2016-07-04'
            cheque_entry.beneficiary_name = nil
            expect(subject.get_bank_name_and_date).to eq([bank, 'Internal Ledger', '2016-07-04'.to_date])
          end
        end
      end
    end
  end

  after do
    travel_back
  end
end
