require 'rails_helper'

RSpec.feature "Branches",type: :feature do
  include_context "feature_session_setup"

  feature "Creating/Updating a branch" do

    it "should create branch successfully" do
      login_as(@user)
      visit "branches/new"
      fill_in "Code", :with=>"Something"
      fill_in "Address", :with=>"Pokhara"
      fill_in "Top nav bar color", :with=>"rgba(255,255,255,1)"
      find('input[name="commit"]').click
      expect(page).to have_text("Branch was successfully created.")
    end

    it "should update branch successfully" do
      @old_branch =  Branch.create!(
          :code => "Danphe",
          :address => "kathmandu",
          :top_nav_bar_color => "rgba(255,255,255,1)")
      login_as(@user)
      visit edit_branch_path(@old_branch)
      fill_in "Code", :with=>"Something"
      fill_in "Address", :with=>"Pokhara"
      fill_in "Top nav bar color", :with=>"rgba(0,0,0,1)"
      find('input[name="commit"]').click
      expect(page).to have_text("Branch was successfully updated.")
    end

  end

end