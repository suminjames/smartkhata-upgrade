require 'rails_helper'

RSpec.describe TransactionMessage, type: :model do
	subject{build(:transaction_message)}
  	include_context 'session_setup'

  	describe ".soft_delete" do
  		it "returns true" do
  			expect(subject.soft_delete).to be_truthy
  		end
  	end

  	describe ".soft_undelete" do
  		it "returns true" do
  			expect(subject.soft_undelete).to be_truthy
  		end
  	end

  	describe "#latest_transaction_date" do
  		it "returns maximum transaction date" do
  			create(:transaction_message, transaction_date: "2017-06-22" )
  			create(:transaction_message, transaction_date: "2017-06-20" )
  			expect(TransactionMessage.latest_transaction_date).to eq("2017-06-22".to_date)
  		end
  	end

    describe ".can_email?" do
      it "returns true" do
        expect(subject.can_email?).to be_truthy
      end
    end

    describe ".can_sms?" do
      it "returns true" do
        allow_any_instance_of(ClientAccount).to receive(:messageable_phone_number).and_return(true)
        expect(subject.can_sms?).to be_truthy
      end
    end

    describe ".increase_sent_email_count" do
      it "increases sent email count" do
        expect()
      end
    end
end