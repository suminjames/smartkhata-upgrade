require 'rails_helper'

RSpec.describe EmployeeAccount, type: :model do
  subject{build(:employee_account, branch_id: branch.id)}
  let(:branch){create(:branch)}
  let(:user){ create(:user) }
  include_context 'session_setup'

  describe "validations" do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:email)}
    it { should allow_value("hello@example.com").for(:email)}
  end
  
  ## validate uniqueness

  describe ".create_ledger" do
    let(:ledger) { create(:ledger, name: "ggghf") }
    before do
      subject.ledgers << ledger
    end

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
      subject{create(:employee_account, name: "john", branch_id: branch.id)}
      it "should return attributes of employee similar to term" do
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
    subject{create(:employee_account, name: "john", branch_id: branch.id)}
    it "should append id with name" do
      expect(subject.name_with_id).to eq("john (#{subject.id})")
    end
  end
end
