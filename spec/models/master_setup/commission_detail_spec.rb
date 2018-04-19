require 'rails_helper'

RSpec.describe  MasterSetup::CommissionDetail do
  include_context 'session_setup'
  subject{ MasterSetup::CommissionDetail.new }

  describe 'validations' do
    context 'when start amount present' do
      it 'checks validity' do
        subject.start_amount = 1000
        subject.limit_amount = nil
        subject.commission_rate = 1.5
        expect(subject).to be_valid
      end
    end
    context 'when start and limit amounts not present' do
      it 'checks validity' do
        subject.start_amount = nil
        subject.limit_amount = nil
        subject.commission_rate = 1.5
        # to check invalidity
        allow(subject).to receive(:set_max_min_amount).and_return(nil)
        allow(subject).to receive(:validate_amounts).and_return(true)
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:start_amount]).to include("can't be blank")
        expect(subject.errors.messages[:limit_amount]).to include("can't be blank")

      end
    end
    context 'when limit amount present' do
      it 'checks validity' do
        subject.start_amount = nil
        subject.limit_amount = 2000
        subject.commission_rate = 1.5
        expect(subject).to be_valid
      end
    end
    context 'when commission rate present' do
      it 'checks validity' do
        subject.start_amount = 1000
        subject.limit_amount = 2000
        subject.commission_rate = 1.5
        expect(subject).to be_valid
      end
    end
    context 'when commission rate not present' do
      it 'checks validity' do
        subject.start_amount = 1000
        subject.limit_amount = 2000
        expect(subject).not_to be_valid
      end
    end
  end

  describe '.validate_amounts' do
    context 'when start amount greater than limit amount' do
      it 'returns error message' do
        subject.start_amount = 1000
        subject.limit_amount = 500
        subject.send(:validate_amounts)
        expect(subject.errors[:start_amount]).to include('Starting price cant be less than the limit')
      end
    end
    context 'when start amount less than limit amount' do
      it 'returns nil' do
        subject.start_amount = 1000
        subject.limit_amount = 2000
        subject.send(:validate_amounts)
        expect(subject.errors[:start_amount]).not_to include('Starting price cant be less than the limit')
      end
    end
  end

  describe '.set_max_min_amount' do
    context 'when start and limit amount blank' do
      it 'returns MAX and MIN valve' do
        subject.send(:set_max_min_amount)
        expect(subject.limit_amount).to eq(99999999999)
        expect(subject.start_amount).to eq(0)
      end
    end
    context 'when start and limit amount present' do
      it 'returns amount' do
        subject.limit_amount = 2000
        subject.start_amount = 1000
        subject.send(:set_max_min_amount)
        expect(subject.limit_amount).to eq(2000)
        expect(subject.start_amount).to eq(1000)
      end
    end
  end
end
