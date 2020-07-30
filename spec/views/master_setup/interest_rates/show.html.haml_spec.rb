require 'rails_helper'

RSpec.describe "master_setup/interest_rates/show", type: :view do
  before(:each) do
    @master_setup_interest_rate = assign(:master_setup_interest_rate, MasterSetup::InterestRate.create!(
      :interest_type => "Interest Type",
      :rate => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Interest Type/)
    expect(rendered).to match(/2/)
  end
end
