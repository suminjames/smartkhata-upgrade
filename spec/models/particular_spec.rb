require 'rails_helper'

RSpec.describe Particular, type: :model do
	subject{build(:particular)}
  	include_context 'session_setup'

  	describe "validations" do
  		it {should validate_presence_of(:ledger_id)}
  	end

  	describe "#with_running_total" do
  		context "when transaction type is cr" do
  			let(:ledger){create(:ledger)}
  			it "should return runnning total" do
  				subject = create(:particular, ledger: ledger, transaction_type: 1, amount:8000)
  				particulars = Particular.with_running_total([subject],1000)
				expect(particulars.first.running_total).to eq(-7000)
  			end
  		end

  		context "when transaction type is dr" do
  			let(:ledger){create(:ledger)}
  			it "should return runnning total" do
  				subject = create(:particular, ledger: ledger, transaction_type: 0, amount:8000)
  				particulars = Particular.with_running_total([subject],1000)
				expect(particulars.first.running_total).to eq(9000)
  			end
  		end
  	end

  	describe ".get_description" do
  		context "when description is present" do
  			subject{create(:particular, description: "description for particular")}
  			it "should return description" do
  				subject.description
  				expect(subject.get_description).to eq("description for particular")
  			end
  		end

  		context "when name is present" do
  			subject{create(:particular, name: "nistha")}
  			it "should return name" do
  				subject.name
  				expect(subject.get_description).to eq("nistha")
  			end
  		end
  	end

  	describe ".process_particular"
end