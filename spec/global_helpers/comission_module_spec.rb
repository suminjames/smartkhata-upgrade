require 'rails_helper'

RSpec.describe CommissionModule, type: :helper do
  let(:dummy_class) { Class.new { extend CommissionModule } }
  let!(:commission_info) {create(:master_setup_commission_info, start_date: "2022-1-1", end_date: "2022-1-10", broker_commission_rate: 1.5, nepse_commission_rate: 2.5)}

  describe '.get_commission_rate' do
    it 'should return commission rate' do
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      expect(dummy_class.get_commission_rate(2000, commission_info)).to eq(1.5)
    end
  end

  describe '.get_commission_info' do
    it 'should return commission info' do
      expect(dummy_class.get_commission_info("2022-1-5")).to eq(commission_info)
    end
  end

  describe '.get_commission_info_with_detail' do
    it 'should return commission info with detail' do
      expect(dummy_class.get_commission_info_with_detail('2022-1-5')).to eq(commission_info)
    end
  end

  describe '.get_commission' do
    it 'should return commission' do
      commission_info.commission_details_array = commission_info.commission_details.order(:start_amount => :asc).to_a
      allow(dummy_class).to receive(:get_commission_by_rate).and_return(30.0)
      expect(dummy_class.get_commission(2000, commission_info)).to eq(30.0)
    end
  end

  describe '.get_commission_by_rate' do
    context 'when commission rate is present' do
      it 'should return commission by rate' do
        expect(dummy_class.get_commission_by_rate(1.5, 2000)).to eq(30.0)
      end
    end

    context 'when commission rate is not present' do
      it 'should return commission by rate' do
        expect(dummy_class.get_commission_by_rate('flat_1.5', 2000)).to eq(1.5)
      end
    end
  end

  describe '.get_commission_rate_array_for_date' do
    let(:commission_detail) {create(:master_setup_commission_detail, master_setup_commission_info_id: commission_info.id, start_amount: 1000, limit_amount: 3000, commission_rate: nil)}
    it 'should return commission rates' do
      commission_info.commission_details << commission_detail
      expect(dummy_class.get_commission_rate_array_for_date('2022-1-5')).to eq(['flat_1.5',1.5])
    end
  end

  describe '.broker_commission' do
    it 'should return broker commission' do
      expect(dummy_class.broker_commission(5, commission_info)).to eq(0.075)
    end
  end

  describe '.nepse_commission_amount' do
    it 'should return nepse commission amount' do
      expect(dummy_class.nepse_commission_amount(5, commission_info)).to eq(0.125)
    end
  end

  describe '.broker_commission_rate' do
    it 'should return broker commission rate' do
      expect(dummy_class.broker_commission_rate('2022-1-5')).to eq(0.975)
    end
  end

  describe '.nepse_commission_rate' do
    it 'should return nepse commission rate' do
      expect(dummy_class.nepse_commission_rate('2022-1-5')).to eq(0.025)
    end
  end

  describe '.date_of_commission_rate_update' do
    it 'should parse date' do
      expect(dummy_class.date_of_commission_rate_update).to eq(Date.parse('2016-7-24'))
    end
  end

end