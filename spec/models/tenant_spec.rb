require 'rails_helper'

RSpec.describe Tenant, type: :model do
	subject{build(:tenant)}
  	include_context 'session_setup'

  	describe ".broker_profile" do
  		let!(:broker_profile){create(:master_broker_profile)}
  		it "returns broker profile" do
  			expect(subject.broker_profile).to eq(broker_profile)
  		end
  	end

  	describe ".dp_id" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, dp_code: 123)}
  			it "returns dp code" do
	  			expect(subject.dp_id).to eq(123)
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns dp id" do
	  			subject.dp_id = "kmkm"
	  			expect(subject.dp_id).to eq("kmkm")
  			end
  		end
  		
  	end

  	describe ".full_name" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, broker_name: "danphe")}
  			it "returns broker name" do
	  			expect(subject.full_name).to eq("danphe")
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns full name" do
	  			subject.full_name = "bjbih"
	  			expect(subject.full_name).to eq("bjbih")
  			end
  		end
  	end

  	describe ".phone_number" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, phone_number: "9842355876")}
  			it "returns phone number" do
	  			expect(subject.phone_number).to eq("9842355876")
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns phone number" do
	  			subject.phone_number = "9803876543"
	  			expect(subject.phone_number).to eq("9803876543")
  			end
  		end
  	end

  	describe ".address" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, address: "kupondole")}
  			it "returns address" do
	  			expect(subject.address).to eq("kupondole")
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns address" do
	  			subject.address = "jawalakhel"
	  			expect(subject.address).to eq("jawalakhel")
  			end
  		end
  	end

  	describe ".pan_number" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, pan_number: "1234")}
  			it "returns pan number" do
	  			expect(subject.pan_number).to eq("1234")
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns pan number" do
	  			subject.pan_number = "786"
	  			expect(subject.pan_number).to eq("786")
  			end
  		end
  	end

  	describe ".fax_number" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, fax_number: "447856")}
  			it "returns fax number" do
	  			expect(subject.fax_number).to eq("447856")
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns fax number" do
	  			subject.fax_number = "423456"
	  			expect(subject.fax_number).to eq("423456")
  			end
  		end
  	end

  	describe ".broker_code" do
  		context "when broker profile is created" do
  			let!(:broker_profile){create(:master_broker_profile, broker_number: 4)}
  			it "returns broker number" do
	  			expect(subject.broker_code).to eq(4)
  			end
  		end

  		context "when broker profile is not created" do
  			it "returns broker code" do
	  			subject.broker_code = "777"
	  			expect(subject.broker_code).to eq("777")
  			end
  		end
  	end

  	describe ".set_attr" do
  		it "returns locale" do
  			subject.send(:set_attr)
  			expect(subject.locale).to eq(:english)
  		end
  	end

end