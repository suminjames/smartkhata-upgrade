require 'rails_helper'

RSpec.describe MenuPermission, type: :model do
	subject{create(:menu_permission)}
  	include_context 'session_setup'

  	describe "#delete_previous_permissions_for" do
  		# might not be necessary
  		it "should delete all previous permissions"
  		
  	end

end