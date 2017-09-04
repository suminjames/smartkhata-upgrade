require 'rails_helper'

describe "Ledger" do
 include_context "feature_session_setup"


  context "signed in user" do
    before do
      login_as(@user, scope: :user)
      @ledger = create(:ledger)
      visit ledger_path(@ledger)
    end

    context "when views by date range" do
      it "should show ledger" do
        expect(page).to have_content(@ledger.name)
      end

      it "should show particulars by date range" do
        click_on "Search by Date Range"
        fill_in "search_term[date_from]", with: '2074/02/28'
        fill_in "search_term[date_to]", with: '2074/02/29'
        click_on 'Search'
        expect(page).to have_content("There are no particulars matching the date range '2074/02/28' to '2074/02/29'.")
      end

    end
  end
end