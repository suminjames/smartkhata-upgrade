require 'rails_helper'

RSpec.describe BranchPermission, type: :model do
   subject {build(:branch_permission)}
  
  include_context 'session_setup'

  describe ".delete_previous_permissions_for" do
  	it do
  		BranchPermission.where(user_id: subject.user_id).delete_all
  	end
  end
end