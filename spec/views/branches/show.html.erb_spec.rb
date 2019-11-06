require 'rails_helper'

RSpec.describe "branches/show", type: :view do
  before(:each) do
    @branch = assign(:branch, Branch.create!(
        :code => "Danphe",
        :address => "kathmandu",
        :top_nav_bar_color => "#ffffff"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/DANPHE/)
    expect(rendered).to match(/kathmandu/)
    expect(rendered).to match(/#ffffff/)
  end
end
