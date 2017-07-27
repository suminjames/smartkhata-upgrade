require 'rails_helper'

RSpec.describe BranchPermissionModule, type: :helper do
  let(:dummy_class) { Class.new { extend BranchPermissionModule } }

  describe "#permitted_branches" do
    let(:branch){create(:branch)}
    let!(:user1){create(:user,role: 4)}
    let(:user2){create(:user, role: 1, branch_id: branch.id, username: "nistha", email: "sample@gmail.com")}
    context "when user is not present" do
      it "should return empty array" do
        expect(dummy_class.permitted_branches(nil)).to eq([])
      end
    end

    context "when user is present" do
      context "and user is not client" do
        it "should return branches" do
          dummy_class.permitted_branches(user1)
          expect(Branch.permitted_branches_for_user(user1).size).to eq(2)
        end
      end

      context "and user is client" do
        it "should return branch" do
          user2
          expect(dummy_class.permitted_branches(user2)).to eq([branch])
        end
      end
    end
  end
end