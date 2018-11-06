	require 'rails_helper'

	RSpec.describe Tenant, type: :model do
		include_context 'session_setup'
		subject{build(:tenant)}
		let!(:ledger){create(:ledger)}

		describe ".broker_profile" do
			let(:master_broker_profile){create(:master_broker_profile, ledger_id: ledger.id, broker_number: 11)}
			let(:broker_profile){create(:broker_profile, ledger_id: ledger.id, broker_number: 12)}
			it "returns broker profile" do
				master_broker_profile
				broker_profile
				expect(subject.broker_profile).to eq(master_broker_profile)
			end

			it "doesnt return broker profile" do
				broker_profile
				expect(subject.broker_profile).to be_nil
			end
		end

		describe ".dp_id" do
			before do
				subject.dp_id = "45"
			end
			context "when broker profile is created" do
				let!(:broker_profile){create(:master_broker_profile, dp_code: 123, ledger_id: ledger.id)}
				it "returns dp code" do
					expect(subject.dp_id).to eq(123)
				end
			end
			context "when broker profile is not created" do
				it "returns dp id from assignment" do
					expect(subject.dp_id).to eq("45")
				end
			end
		end

		describe ".full_name" do
			context "when broker profile is created" do
				let!(:broker_profile){create(:master_broker_profile, broker_name: "danphe", ledger_id: ledger.id)}
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
				let!(:broker_profile){create(:master_broker_profile, phone_number: "9842355876", ledger_id: ledger.id)}
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
				let!(:broker_profile){create(:master_broker_profile, address: "kupondole", ledger_id: ledger.id)}
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
				let!(:broker_profile){create(:master_broker_profile, pan_number: "1234", ledger_id: ledger.id)}
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
				let!(:broker_profile){create(:master_broker_profile, fax_number: "447856", ledger_id: ledger.id)}
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
				let!(:broker_profile){create(:master_broker_profile, broker_number: 4, ledger_id: ledger.id)}
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
