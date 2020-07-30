require 'rails_helper'

RSpec.describe "master_setup/interest_rates/edit", type: :view do
  before(:each) do
    @master_setup_interest_rate = assign(:master_setup_interest_rate, MasterSetup::InterestRate.create!(
      :interest_type => "MyString",
      :rate => 1
    ))
  end

  it "renders the edit master_setup_interest_rate form" do
    render

    assert_select "form[action=?][method=?]", master_setup_interest_rate_path(@master_setup_interest_rate), "post" do

      assert_select "input#master_setup_interest_rate_interest_type[name=?]", "master_setup_interest_rate[interest_type]"

      assert_select "input#master_setup_interest_rate_rate[name=?]", "master_setup_interest_rate[rate]"
    end
  end
end
