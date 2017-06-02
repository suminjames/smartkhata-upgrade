require 'rails_helper'

RSpec.describe Group, type: :model do
	# subject {build(:group)}
  	include_context 'session_setup'

  describe "validations" do
  	it { should validate_uniqueness_of(:name)}
  
  end
end