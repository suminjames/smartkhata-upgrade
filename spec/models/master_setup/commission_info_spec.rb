require 'rails_helper'

RSpec.describe  MasterSetup::CommissionInfo do
  include_context 'session_setup'
  let(:master_setup_commission_info){create(:master_setup_commission_info, start_date: "2022-1-1", end_date: "2022-1-10", sebo_rate: 0.15)}
  let(:commission_detail){create(:master_setup_commission_detail, start_amount: 1000, limit_amount: 2000, master_setup_commission_info_id: master_setup_commission_info.id)}
  let(:another_commission_detail){create(:master_setup_commission_detail, start_amount: 500, limit_amount: 1500, master_setup_commission_info_id: master_setup_commission_info.id)}
  subject { MasterSetup::CommissionInfo.new }

  describe 'validations' do
    context 'when nepse commission rate present' do
      it 'checks validity' do
        subject = master_setup_commission_info
        expect(subject).to be_valid
      end
      context 'and is out of range' do
        it 'checks validity' do
          subject = master_setup_commission_info
          subject.nepse_commission_rate = 101
          expect(subject).not_to be_valid
        end
      end
    end
    context 'when nepse commission rate not present' do
      it 'checks validity' do
        subject = master_setup_commission_info
        subject.nepse_commission_rate = nil
        expect(subject).not_to be_valid
      end
    end
  end

  describe '.is_latest?' do
    it 'returns true' do
      subject = master_setup_commission_info
      expect(subject.is_latest?).to eq(true)
    end
  end

  describe '.validate_date_range' do
    context 'when start date is greater than end date' do
      it 'returns error message' do
        subject = master_setup_commission_info
        subject.start_date = '2022-1-11'
        subject.send(:validate_date_range)
        expect(subject.errors[:start_date]).to include('Start date should be before the end date')
      end
    end

    context 'when date already included' do
      it 'adds error' do
        master_setup_commission_info
        subject.start_date = '2022-1-3'
        subject.end_date = '2022-1-10'
        subject.send(:validate_date_range)
        expect(subject.errors[:base]).to include('Date is already Included. Please review')
      end
    end

    context 'when end date not equal to yesterday of start date' do
      it 'returns' do
        master_setup_commission_info
        subject.start_date = '2022-1-12'
        subject.end_date = '2022-1-20'
        subject.send(:validate_date_range)
        expect(subject.errors[:base]).to include('Entry missing for dates before the starting date')
      end
    end
  end

  describe '.validate_details' do
    context 'when common start amount presents' do
      it 'adds error' do
        another_commission_detail.start_amount = 1000
        subject = master_setup_commission_info
        subject.commission_details << commission_detail
        subject.commission_details << another_commission_detail
        subject.send(:validate_details)
        expect(subject.errors[:base]).to include('Invalid Data')
      end
    end

    context 'when common limit amount presents' do
      it 'adds error' do
        another_commission_detail.limit_amount = 2000
        subject = master_setup_commission_info
        subject.commission_details << commission_detail
        subject.commission_details << another_commission_detail
        subject.send(:validate_details)
        expect(subject.errors[:base]).to include('Invalid Data')
      end
    end

    context 'when start amount not equal to min(0)' do
      it 'adds error' do
        subject = master_setup_commission_info
        subject.commission_details << commission_detail
        subject.commission_details << another_commission_detail
        subject.commission_details.first.start_amount = 500
        subject.send(:validate_details)
        expect(subject.errors[:base]).to include('At least one detail should be present and have min amount')
      end
    end

    context 'when limit amount not equal to max(99999999999) ' do
      it 'adds error' do
        subject = master_setup_commission_info
        subject.commission_details << commission_detail
        subject.commission_details << another_commission_detail
        subject.commission_details.first.limit_amount = 1000
        subject.send(:validate_details)
        expect(subject.errors[:base]).to include('At least one detail should address the max amount')
      end
    end

    context 'when limit amounts not equal to starting amounts' do
      it 'adds error' do
        subject = master_setup_commission_info
        subject.commission_details << commission_detail
        subject.commission_details << another_commission_detail
        subject.send(:validate_details)
        expect(subject.errors[:base]).to include('Invalid Data')
      end
    end
  end
end
