require 'rails_helper'

RSpec.describe Branch, type: :model do
  subject {build(:branch)}

  include_context 'session_setup'

  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:address) }
    it { should validate_uniqueness_of(:code).case_insensitive }
  end

  describe "#permitted_branches_for_user" do
    # since session setup creates a branch which is necessary due to app logic
    # same case with user
    let!(:branch_1) { Branch.first }
    let!(:branch_2) { create(:branch) }
    let(:user) { @user }

    # before do
    #   branch_1
    #   branch_2
    # end


    context "when admin" do
      it "should permit all branches" do
        user.admin!
        expect(subject.class.permitted_branches_for_user(user).size).to eq(3)
      end
    end

    context "when user is employee" do
      context "when user has access to all branches"  do
        it "should return branches plus an all option" do
          user.employee!
          expected = [branch_1.id, branch_2.id]
          allow(BranchPermission).to receive(:where).with({user_id: user.id}).and_return(double(pluck: expected))
          expect(subject.class.permitted_branches_for_user(user).size).to eq(3)
        end
      end
      context "when user has access to some branches" do
        before do
          user.employee!
          expected = [branch_1.id]
          allow(BranchPermission).to receive(:where).with({user_id: user.id}).and_return(double(pluck: expected))
        end

        it "should return branches without all option" do

          expect(subject.class.permitted_branches_for_user(user).size).to eq(1)
        end

        it "should return the branch that user has permission" do
          expect(subject.class.permitted_branches_for_user(user).include? branch_1).to be_truthy
        end

      end
    end
  end

  describe ".code" do
    it "should store code in uppercase" do
      subject.code = "danphe"
      expect(subject.code).to eq('DANPHE')
    end

    it "should not store blank codes" do
      subject.code = ""
      subject.address = "kathmandu"
      expect(subject.save).to eq(false)
    end
  end

  describe ".top_nav_bar_color" do
    it "should be able to store nil variables" do
      subject.code = "danphe"
      subject.address = "kathmandu"
      subject.top_nav_bar_color = nil
      expect(subject.save).to eq(true)
    end

    it "should not be required" do
      subject.code = "danphe"
      subject.address = "kathmandu"
      expect(subject.save).to eq(true)
    end
  end

  describe "#has_multiple_branches?" do
    let!(:branch_1) { Branch.first }
    let(:branch_2) { create(:branch) }

    context "when branch size is greater than 1" do
      it "should return true" do
        # branch_1
        branch_2
        expect(Branch.has_multiple_branches?).to be_truthy
      end
    end

    context "when branch size is not greater than 1" do
      it "should return false" do
        expect(Branch.has_multiple_branches?).not_to be_truthy
      end
    end
  end

  describe "#selected_branch" do
    let(:branch){ create(:branch) }
    it "should return selected branch from the dashboard" do
      expect(Branch.selected_branch(branch)).to eq(branch)
    end

    it "should return error for nil branch" do
       expect(Branch.selected_branch(nil)).to be_nil
    end
  end
end