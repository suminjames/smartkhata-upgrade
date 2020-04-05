require 'rails_helper'

RSpec.describe EmployeeAccount, type: :model do
  include_context 'session_setup'
  subject{create(:employee_account, user_id: @user.id)}

  describe "validations" do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:email)}
    it { should validate_uniqueness_of(:email)}
    it { should allow_value("hello@example.com").for(:email)}
  end

  describe ".create_ledger" do
    it "should create a ledger with same name" do
  		expect(Ledger.where(employee_account_id: subject.id).first.name).to eq(subject.name)
  	end
  end

  describe ".assign_group" do
    it "should assign the employee ledger to 'Employees' group" do
    end
  end

  describe "#find_similar_to_term" do
    context "when search term is present" do
      it "should return attributes of employee similar to term" do
        subject.name = 'john'
        subject.save!
        expect(subject.class.find_similar_to_term("jo")).to eq([:text => "john (#{subject.id})", :id => "#{subject.id}"])
      end
    end
  end

  # describe ".user_access_role_id" do
  #   let(:user_access_role) {UserAccessRole.create(role_type: 'employee', role_name: 'asdf')}
  #   it "should return user access role id"
  #   # do
  #   # dont think this is required(SUBAS)
  #
  #   # employee = create(:employee_account, name: "nistha")
  #   # allow(employee).to receive(:user_access_role).and_return(user_access_role)
  #   # expect(employee.user_access_role_id).to eq(user_access_role.id)
  #   # end
  # end

  describe ".name_with_id" do
    it "should append id with name" do
      subject.name = 'john'
      expect(subject.name_with_id).to eq("john (#{subject.id})")
    end
  end
end
