require 'rails_helper'

RSpec.describe BranchPermission, type: :model do
   subject {create(:branch_permission)}
  
  include_context 'session_setup'

  describe "#delete_previous_permissions_for" do
  	it " should delete previous permissions" do
  		subject
  		expect { BranchPermission.delete_previous_permissions_for(subject.user_id) }.to change {BranchPermission.count}.by(-1)

  	end

  	it " should delete all previous permissions" do
  		BranchPermission.delete_previous_permissions_for(subject.user_id)
  		expect(BranchPermission.where(user_id: subject.user_id).count).to eq(0)

  	end

  end
end