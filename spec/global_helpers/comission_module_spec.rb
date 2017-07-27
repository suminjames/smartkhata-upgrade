require 'rails_helper'

RSpec.describe CommissionModule, type: :helper do
  let(:dummy_class) { Class.new { extend CommissionModule } }

end