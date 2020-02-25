require 'rails_helper'

RSpec.feature "Ledger", type: :feature do
  include_context "feature_session_setup"
#  let(:user) {create(:user, role: 0, username: "john", email: "john@gmail.com", branch_id: @branch.id) }
  let(:tenant) {Tenant}
  let(:ledger) {create(:ledger)}
  let(:ledger2) {create(:ledger, name: "User1")}
  let(:ledger1) {create(:ledger, name:"Purchase Commission")}
  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end
  context "signed in user", js: true  do
    before do
      login_as(@user, scope: :user)
      visit ledgers_merge_ledger_path(selected_fy_code: 7677, selected_branch_id: 1)
      ledger
    end
    it "sucessfully merge ledgers" do
      expect(page).to have_content('Merge Ledgers')
      select_helper( ledger.name, "ledgers_index_combobox")
      select_helper( ledger2.name, "ledgers_index_combobox_1")
      find('.btn-primary').click
      expect(page).to have_content('Sucessfully Ledger Merge')
    end

    it "unsucessfully ledgers merge" do
      expect(page).to have_content('Merge Ledgers')
      select_helper( ledger.name, "ledgers_index_combobox")
      select_helper( ledger1.name, "ledgers_index_combobox_1")
      find('.btn-primary').click
      expect(page).to have_content('Ledger Merge Unsucessfull')
    end
  end
end
