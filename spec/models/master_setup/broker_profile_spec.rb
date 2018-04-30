require 'rails_helper'

RSpec.describe  MasterSetup::BrokerProfile do
  include_context 'session_setup'
  let(:master_broker_profile1){create(:master_broker_profile, locale: 0)}
  let(:master_broker_profile2){create(:master_broker_profile, locale: 1)}
  subject{ MasterSetup::BrokerProfile.new }

  describe '#has_profile_in' do
    context 'when count of broker profile for matched locale greater than 0' do
      it 'returns true' do
        master_broker_profile1
        expect(subject.class.has_profile_in(:english)).to eq(true)
      end
    end
    context 'when count of broker profile for matched locale is 0' do
      it 'returns false' do
        expect(subject.class.has_profile_in(:english)).to eq(false)
      end
    end
  end

  # there should not be more than two MasterSetup::BrokerProfile
  describe '#has_maximum_records?' do
    context 'when two MasterSetup::BrokerProfile' do
      it 'returns true' do
        master_broker_profile1
        master_broker_profile2
        expect(subject.class.has_maximum_records?).to eq(true)
      end
    end
    context 'when less than two MasterSetup::BrokerProfile' do
      it 'returns false' do
        master_broker_profile1
        expect(subject.class.has_maximum_records?).to eq(false)
      end
    end
  end

  describe '.single_locale_record' do
    context 'when locale matched to existing broker profile' do
      it 'returns error message' do
        subject.locale = 'english'
        master_broker_profile1
        subject.single_locale_record
        expect(subject.errors[:locale]).to include('There is already another Broker Profile for english locale.')
      end
    end
    context 'when locale unmatched to existing broker profile' do
      it 'returns nil' do
        subject.locale = 'english'
        expect(subject.single_locale_record).to eq(nil)
      end
    end
  end
end
