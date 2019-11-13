require 'rails_helper'

RSpec.feature "Ledger", type: :feature do
  include_context "feature_session_setup"
#  let(:user) {create(:user, role: 0, username: "john", email: "john@gmail.com", branch_id: @branch.id) }
  let(:tenant) {Tenant}
  let(:ledger) {create(:ledger)}
  let(:ledger1) {create(:ledger, name:"Purchase")}
  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end
  context "signed in user", js: true  do
    before do
      login_as(@user, scope: :user)
      visit ledgers_merge_ledger_path
      ledger
    end
    it "sucessfully merge ledgers" do
      expect(page).to have_content('Merge Ledgers')
      find('#ledgers_index_combobox').click
      find('input').set("Cash")
      find('#ledgers_index_combobox').first(:option)
      find('#ledgers_index_combobox_1').click
      find('input').set("Purchase")
      find('#ledgers_index_combobox_1').first(:option).click
      find('.btn-primary').click
      expect(page).to have_content('Sucessfully Ledger Merge')
    end
    it "unsucessfully ledgers merge" do
      expect(page).to have_content('Merge Ledgers')
      find('#ledgers_index_combobox').click
      find('input').set("Cash")
      find('#ledgers_index_combobox').first(:option)
      find('#ledgers_index_combobox_1').click
      find('input').set("Purchase")
      find('#ledgers_index_combobox_1').first(:option).click
      find('.btn-primary').click
      expect(page).to have_content('Ledger Merge Unsucessfull')
    end
  end
end
