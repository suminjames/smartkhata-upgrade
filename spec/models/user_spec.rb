require 'rails_helper'

RSpec.describe User, type: :model do
  subject {build(:user)}

  describe "validations" do
    it { expect(subject).to be_valid }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }

    context "email absent but username present" do
      before { allow(subject).to receive(:email).and_return(nil) }
      it { expect(subject).to be_valid }
    end

    context "username absent but email present" do
      before { allow(subject).to receive(:username).and_return(nil) }
      it { expect(subject).to be_valid }
    end

    it { should validate_length_of(:password).is_at_most(20) }
    it { should validate_length_of(:password).is_at_least(4) }
  end

  describe "role" do
    it "allows the role to updated" do
      subject.save
      subject.role = subject.class.roles[:admin]
      expect(subject).to be_valid
    end
  end

end