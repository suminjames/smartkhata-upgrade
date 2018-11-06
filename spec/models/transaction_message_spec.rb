require 'rails_helper'

RSpec.describe TransactionMessage, type: :model do
  include_context 'session_setup'
  subject{create(:transaction_message)}

  describe ".soft_delete" do
    it "returns true" do
      subject.soft_delete
      expect(subject.deleted_at).not_to be_nil
    end
  end

  describe ".soft_undelete" do
    it "returns true" do
      subject.soft_undelete
      expect(subject.deleted_at).to be_nil
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
    let!(:client_account){create(:client_account, email: "jnjn@gmail.com")}
    it "returns true" do
      subject.client_account_id = client_account.id
      expect(subject.can_email?).to be_truthy
    end
  end

  describe ".can_sms?" do
    it "returns true" do
      allow_any_instance_of(ClientAccount).to receive(:messageable_phone_number).and_return("9841266550")
      expect(subject.can_sms?).to be_truthy
    end
  end

  describe ".increase_sent_email_count" do
    it "increases sent email count" do
      expect{subject.increase_sent_email_count!}.to change{subject.sent_email_count}.by(1)
    end
  end

   describe ".increase_sent_sms_count" do
    it "increases sent sms count" do
      expect{subject.increase_sent_sms_count!}.to change{subject.sent_sms_count}.by(1)
    end
  end
end