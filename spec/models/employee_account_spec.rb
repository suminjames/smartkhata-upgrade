require 'rails_helper'

RSpec.describe EmployeeAccount, type: :model do
	subject{build(:employee_account)}
  	include_context 'session_setup'

  describe "validations" do
  	it { should validate_presence_of(:name)}
  	it { should validate_presence_of(:email)}
  	it { should validate_uniqueness_of(:email)}
  	it { should allow_value("hello@example.com").for(:email)}
  end

  describe ".create_ledger" do
  	subject{create(:employee_account)}

  	it "should create a ledger with same name" do
  		expect(Ledger.where(employee_account_id: subject.id).first.name).to eq(subject.name)
  	end

  	it "should assign employee_account id to ledger" do
  		# expect(subject.ledgers.first.employee_id).to eq(subject.id)
  	end

  end
end