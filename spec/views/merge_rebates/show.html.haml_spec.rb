require 'rails_helper'

RSpec.describe "merge_rebates/show", type: :view do
  before(:each) do
    @merge_rebate = assign(:merge_rebate, MergeRebate.create!(
      :scrip => "Scrip"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Scrip/)
  end
end
