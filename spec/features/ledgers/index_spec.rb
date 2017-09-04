require 'rails_helper'

describe "Ledger" do
  include_context "feature_session_setup"
  # let(:user) {create(:user)}
  let(:user_employee) {create(:user, role: 3, username: "john", email: "john@gmail.com", branch_id: @branch.id) }
  let(:tenant) {Tenant}

  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
  end

  after(:each) do
    Warden.test_reset!
  end

  context "signed in user" do
    before do
      login_as(@user, scope: :user)
      @client_account = create(:client_account, name: "Anita", nepse_code: "A123")
      bill = create(:bill, status: 0)
      @client_account.bills << bill
      ledger_balance = create(:ledger_balance, opening_balance: 300, fy_code: 7475, branch_id: 1)
      cheque_entry = create(:cheque_entry, cheque_number: 1111)
      particular = create(:particular, fy_code: 7475, transaction_date: "2017-08-31")
      particular.cheque_entries << cheque_entry
      @client_account.ledger.branch_id = 1
      @client_account.ledger.fy_code = 7475
      @client_account.ledger.particulars << particular
      @client_account.ledger.ledger_balances << ledger_balance
      visit ledgers_path
    end

    context "when user is admin" do
      it "should show ledger list", js:true do
        expect(page).to have_content("Ledgers")
        expect(page).to have_content("Anita")
        expect(page).to have_content("Show")
        expect(page).to have_content("Clear Ledger")
        expect(page).to have_content("Process Selected Bills")
        page.execute_script(%Q($('select#ledgers_index_combobox').select2('open')))
        page.execute_script(%Q($(".select2-search__field").val('#{@client_account.name}')))
        page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
        sleep(2)
        page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))
        click_on "Search"
        expect(page).to have_content("Anita")
        expect(page).to have_content("Show")
        expect(page).to have_content("Clear Ledger")
        expect(page).to have_content("Process Selected Bills")

        within('table.ledger-list') do
          click_on "Show"
        end

        sleep(1)
        expect(page).to have_content("Opening Balance")
        expect(page).to have_content("Closing Balance")
        expect(page).to have_content("Clear Ledger")
        expect(page).to have_content("Process Selected Bills")
        expect(page).to have_content("Cheque")
        expect(page).to have_content("1111")

        click_on "1111"
        expect(page).to have_content("Cheque details")
        expect(page).to have_selector(".btn")

      end
    end

  end

  context "signed in employee user" do
    before do
      user_employee
      allow_any_instance_of(LedgersController).to receive(:get_preferrable_branch_id).and_return(Branch.first.id)
      allow(user_employee).to receive(:user_access_role).and_return(UserAccessRole.new(:access_level => 0))
      # by pass permission
      allow(MenuItem).to receive(:black_listed_paths_for_user).and_return([])
      # allow(Branch).to receive(:permitted_branches_for_user).and_return(Branch.all)

      UserSession.set_usersession_for_test(7374, @branch.id, user_employee )
      login_as(user_employee, scope: :user)
      @client_account = create(:client_account, name: "Anita", nepse_code: "A123")
      bill = create(:bill, status: 0)
      @client_account.bills << bill
      ledger_balance = create(:ledger_balance, opening_balance: 300, fy_code: 7475, branch_id: @branch.id)
      cheque_entry = create(:cheque_entry, cheque_number: 1111)
      particular = create(:particular, fy_code: 7475, transaction_date: "2017-08-31")
      particular.cheque_entries << cheque_entry
      @client_account.ledger.branch_id = @branch.id
      @client_account.ledger.fy_code = 7475
      @client_account.ledger.particulars << particular
      @client_account.ledger.ledger_balances << ledger_balance
      visit ledgers_path
    end

    context "when user is not admin" do
      it "should show ledger list", js:true do
        expect(page).to have_content("Ledgers")
        expect(page).to have_content("Anita")
        expect(page).to have_content("Show")
        expect(page).not_to have_content("Clear Ledger")
        expect(page).not_to have_content("Process Selected Bills")
        page.execute_script(%Q($('select#ledgers_index_combobox').select2('open')))
        page.execute_script(%Q($(".select2-search__field").val('Anita')))
        page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
        sleep(3)
        page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))
        click_on "Search"
        expect(page).to have_content("Anita")
        expect(page).to have_content("Show")
        expect(page).not_to have_content("Clear Ledger")
        expect(page).not_to have_content("Process Selected Bills")
        click_on "Show"
        expect(page).to have_content("Opening Balance")
        expect(page).to have_content("Closing Balance")
        expect(page).not_to have_content("Clear Ledger")
        expect(page).not_to have_content("Process Selected Bills")
        expect(page).to have_content("Cheque")
        expect(page).to have_content("1111")
        # click_on "1111"
        # sleep(1)
        # expect(page).to have_content("Cheque details")
      end
    end
  end
end