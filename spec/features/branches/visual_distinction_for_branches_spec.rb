require 'rails_helper'

RSpec.feature "Branches",type: :feature do
  include_context "feature_session_setup"

  feature "Creating/Updating a branch" do
    it "should create branch successfully" do
      login_as(@user)
      visit "branches/new"
      fill_in "Code", :with=>"Something"
      fill_in "Address", :with=>"Pokhara"
      fill_in "Top nav bar color", :with=>"#ffffff"
      find('input[name="commit"]').click
      expect(page).to have_text("Branch was successfully created.")
    end

    it "should update branch successfully" do
      @old_branch =  Branch.create!(
          :code => "Danphe",
          :address => "kathmandu",
          :top_nav_bar_color => "#ffffff")

      login_as(@user)
      visit edit_branch_path(@old_branch)
      fill_in "Code", :with=>"Something"
      fill_in "Address", :with=>"Pokhara"
      fill_in "Top nav bar color", :with=>"#ffffff"
      find('input[name="commit"]').click
      expect(page).to have_text("Branch was successfully updated.")
    end

    it "should change the color of navbar when selecting color" do
      login_as(@user)
      visit "branches/new"

      page.execute_script("$('selector').css('property','value')")
      navbar_color = find('nav')['style']['background-color']
      find('div#color1').click
      box_color = find('div#color1')['style']['background-color']


      expect(navbar_color).to eq(box_color)

    end
  end

end