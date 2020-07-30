require 'rails_helper'

RSpec.describe "master_setup/interest_rates/index", type: :view do
  before(:each) do
    assign(:master_setup_interest_rates, [
      MasterSetup::InterestRate.create!(
        :interest_type => "Interest Type",
        :rate => 2
      ),
      MasterSetup::InterestRate.create!(
        :interest_type => "Interest Type",
        :rate => 2
      )
    ])
  end

  it "renders a list of master_setup/interest_rates" do
    render
    assert_select "tr>td", :text => "Interest Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
