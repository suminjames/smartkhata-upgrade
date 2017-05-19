require 'rails_helper'

RSpec.describe BrokerProfile, type: :model do

  include_context 'session_setup'

  describe "validations" do
  	before do
  		# subject {build(:broker_profile)}
  		# allow(subject).to receive(:strip_blanks).and_return(subject.broker_name, subject.broker_number)
  		allow_any_instance_of(BrokerProfile).to receive(:strip_blanks).and_return("asf", "ggf")
  	end
  	it { should validate_presence_of (:broker_name)}
  	it { should validate_presence_of (:broker_number)}
  	it { should validate_presence_of (:address)}
  	it { should validate_presence_of (:fax_number)}
  	it { should validate_presence_of (:pan_number)}
  	it { should validate_presence_of (:locale)}
  	it { should validate_uniqueness_of(:broker_number).scoped_to(:locale)}
  end
end
