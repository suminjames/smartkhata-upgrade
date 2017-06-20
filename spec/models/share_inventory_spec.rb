require 'rails_helper'

RSpec.describe ShareInventory, type: :model do
	subject{build(:share_inventory)}
  include_context 'session_setup'

  describe "#with_most_quantity" do
  	it "return info with high quantity"
  
  end

end