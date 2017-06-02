require 'rails_helper'

RSpec.describe Closeout, type: :model do

  include_context 'session_setup'

  describe "validations" do
  	it { should validate_presence_of (:net_amount)}
  end
end