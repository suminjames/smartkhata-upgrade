require 'rails_helper'

RSpec.describe MenuPermission, type: :model do
	include_context 'session_setup'

	subject{create(:menu_permission, user_id: @user_id)}


	# describe "#delete_previous_permissions_for" do
	# 	# might not be necessary
	#
	# 	it "should delete all previous permissions"
	# end

end