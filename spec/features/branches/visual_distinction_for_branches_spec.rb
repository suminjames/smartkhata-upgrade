require 'rails_helper'

RSpec.feature "Branches",type: :feature do
  include_context "feature_session_setup"

  feature "Change navbar color when selecting a branch", js: true do
    let(:branch){create(:branch)}
    it "should change the color of navbar when selecting a branch" do
      login_as(@user)
      @branch.update(top_nav_bar_color: "rgba(255, 123, 233, 1)")
      @new_branch = Branch.create(code: "PKR", address: "Pokhara", top_nav_bar_color: "rgba(0, 0, 0, 0)")
      visit root_path
      navbar_color = page.find(:css, 'nav').native.style('background-color')
      expect(navbar_color).to eq(@branch.top_nav_bar_color)
      expect(page).to have_select('branch_id', selected: "BRANCH-1")
      assert_page_reloads do
        select_branch("PKR")
      end
      expect(page).to have_select('branch_id', selected: "PKR")
      navbar_color_after_reload = page.find(:css, 'nav').native.style('background-color')
      expect(navbar_color_after_reload).to eq(@new_branch.top_nav_bar_color)
    end
  end

  feature "Change navbar color when selecting color in update/create view", js: true do
    it "should change the color of navbar when selecting from colored box" do
      login_as(@user)
      visit "branches/new"
      page.execute_script("$('nav').css('backgroundColor','#ffffff')")
      find('div#green').click
      box_color = page.find(:css, 'div#green').native.style('background-color')
      navbar_color = page.find(:css, 'nav').native.style('background-color')
      expect(navbar_color).to eq(box_color)
    end

    it "should change the color of navbar when selecting from colorpicker" do
      login_as(@user)
      visit "branches/new"
      page.execute_script("$('nav').css('backgroundColor','#000000')")
      color_picker = find("input#branch_top_nav_bar_color")
      color_picker.set("rgba(0, 0, 0, 1)")
      navbar_color = page.find(:css, 'nav').native.style('background-color')
      expect(navbar_color).to eq(color_picker.value)
    end
  end



  def select_branch(code)
    branch_selector = page.find('.fy-selection').find('.fire-on-select').find('#branch_id')
    branch_selector.find(:option, code).select_option
  end

  def assert_page_reloads(message = "page should reload")
    page.evaluate_script "document.body.classList.add('not-reloaded')"
    yield
    return unless has_selector? "body.not-reloaded"

    assert false, message
  end
end