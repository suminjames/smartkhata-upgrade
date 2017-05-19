require 'rails_helper'

RSpec.describe ShareTransaction, type: :model do
  	include_context 'session_setup'
 
  	describe "validations" do
  		it {should validate_numericality_of(:base_price)}
  	end
end