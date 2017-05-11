require 'rails_helper'

RSpec.describe Bill, type: :model do
  subject {build(:bill)}
  
  include_context 'session_setup'

  describe "validations" do
  	it {should validate_presence_of (:client_account)}
  end

  it "should be valid" do
  	expect(subject).to be_valid
  end

  it "client_account_id should not be empty" do
  	subject.client_account_id = ''
  	expect(subject).not_to be_valid
  end

  it "client_account_id should not be imaginary" do
  	subject.client_account_id = '3740237'
  	expect(subject).not_to be_valid
  end

end