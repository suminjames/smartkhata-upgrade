require 'rails_helper'

RSpec.describe BrokerProfile, type: :model do
  subject {build(:broker_profile)}
  include_context 'session_setup'

  describe "validations" do
  	before do
  		# subject {build(:broker_profile)}
  		# allow(subject).to receive(:strip_blanks).and_return(subject.broker_name, subject.broker_number)
  		allow_any_instance_of(BrokerProfile).to receive(:strip_blanks).and_return("asf", 123)
  	end
  	it { should validate_presence_of(:broker_name)}
  	it { should validate_presence_of(:broker_number)}
  	# it { should validate_presence_of (:address)}
  	# it { should validate_presence_of (:fax_number)}
  	# it { should validate_presence_of (:pan_number)}
  	# it { should validate_presence_of (:locale)}
    it { should validate_numericality_of(:broker_number)}
  	it { should validate_uniqueness_of(:broker_number).scoped_to(:locale)}
  end

  describe ".ledger map" do
    let(:ledger) {build(:ledger)}
    context "when ledger is present" do
      it "should return ledger" do
        subject.ledger = ledger
        expect(subject.ledger_map).to eq([subject.ledger])
      end
    end
  end

  describe ".strip_blanks" do

    it "should test private method" do
      broker_profile = build(:broker_profile)
      broker_profile.broker_name = "danphe "
      # broker_profile.broker_number = "  12334"
      broker_profile.send(:strip_blanks, :broker_name)

      expect(broker_profile.broker_name).to eq('danphe')
      # expect(broker_profile.broker_number).to eq('12334')
    end
  end

  describe ".assign default locale" do
    context "when locale is not present" do
      it "should assign default locale when locale is nil" do
        subject.locale = nil
        subject.send(:assign_default_locale)
        expect(subject.locale).to eq('english')
      end
    end

    context "when locale is present" do
      it "should assign locale" do
        subject.locale = 1
        subject.send(:assign_default_locale)
        expect(subject.locale).to eq('nepali')
      end
    end
  end
end
