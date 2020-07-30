require 'rails_helper'

RSpec.describe "master_setup/interest_rates/new", type: :view do
  before(:each) do
    assign(:master_setup_interest_rate, MasterSetup::InterestRate.new(
      :interest_type => "MyString",
      :rate => 1
    ))
  end

  it "renders new master_setup_interest_rate form" do
    render

    assert_select "form[action=?][method=?]", master_setup_interest_rates_path, "post" do

      assert_select "input#master_setup_interest_rate_interest_type[name=?]", "master_setup_interest_rate[interest_type]"

      assert_select "input#master_setup_interest_rate_rate[name=?]", "master_setup_interest_rate[rate]"
    end
  end
end
