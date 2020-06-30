require 'rails_helper'

RSpec.describe "merge_rebates/index", type: :view do
  before(:each) do
    assign(:merge_rebates, [
      MergeRebate.create!(
        :scrip => "Scrip"
      ),
      MergeRebate.create!(
        :scrip => "Scrip"
      )
    ])
  end

  it "renders a list of merge_rebates" do
    render
    assert_select "tr>td", :text => "Scrip".to_s, :count => 2
  end
end
