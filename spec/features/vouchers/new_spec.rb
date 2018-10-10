  require 'rails_helper'

  # require 'capybara/poltergeist'
  # Capybara.javascript_driver = :poltergeist

  include FiscalYearModule
  describe "New Voucher" do
    include_context 'feature_session_setup'
    # let(:user) {create(:user)}
    let(:tenant) {Tenant}
    let(:get_fy_code){FiscalYearModule.get_fy_code}
    before(:each) do
      UserSession.set_console('public')
      allow_any_instance_of(ApplicationController).to receive(:current_tenant).and_return(build(:tenant))
    end

    shared_examples "input particular narration", js: true do|count = 1|
      it "should input particular Narration" do
        expect(page).to have_content("Add Narration")
        expect(all('.narration-display').size).to eq(count)

        expect(all('.particular-narration input').size).to eq(0)
        # narration_display: class of element
        page.first('.narration-display').click
        # checks for the presence of the input tag
        expect(all('.particular-narration input').size).to eq(1)
      end
    end

    shared_examples "add particular", js:true do|count= 1|
      it "should add particular field" do
        expect(page).to have_content("Add Particular")
        expect(all('.particular-container').size).to eq(count)
        page.first('.add_fields').click
        expect(all('.particular-container').size).to eq(count+1)
      end
    end

    shared_examples "add particular for receipt", js:true do|count= 2|
      it "should add particular field" do
        expect(page).to have_content("Add Particular")
        expect(all('.particular-container').size).to eq(count)
        page.first('.add_fields').click
        first_count = count+1
        expect(all('.particular-container').size).to eq(first_count)
        fields = page.all('.add_fields')
        fields[-1].click
        expect(all('.particular-container').size).to eq(first_count+1)
      end
    end

    shared_examples "invalid fy_code" do
      it "does not creates payment voucher", js: true do
        voucher_form_submit
        expect(page).to have_content("Invalid Date for fiscal year!")
      end
    end

    def voucher_form_submit
      voucher_dr_amount = voucher_cr_amount = 4000
      voucher_dr_cheque_number = 1111
      fill_in "voucher_particulars_attributes_0_amount", with: voucher_cr_amount
      find("input[id$='voucher_particulars_attributes_0_cheque_number']").set voucher_dr_cheque_number
      select_helper(@client_account.name,"voucher_particulars_attributes_3_ledger_id" )
      fill_in "voucher_particulars_attributes_3_amount", with: voucher_dr_amount
      add_narrations = page.all(".narration-display")
      add_narrations[-1].click
      fill_in "voucher_particulars_attributes_3_description", with: "description for particular"
      fill_in "voucher_desc", with: 'sample test for payment voucher'
      # click_on methods expects id, name, value of the button
      click_on 'Submit'
    end

    context "signed in user" do
      before(:each) do
        login_as(@user, scope: :user)
        setup_spec if defined? setup_spec
      end

      context "when payment voucher" do
        before do
          @bank_account = create(:bank_account, branch_id: @branch.id, ledger: create(:ledger, name: "Bank:1"))
          @client_account = create(:client_account, name: "Subash Adhikari")
          Ledger.find_or_create_by(name: "Cash")
          visit new_voucher_path(voucher_type: Voucher.voucher_types[:payment])
        end

        it_behaves_like "invalid fy_code"

        context "and valid date for fy" do

          let(:setup_spec) {
            UserSession.set_usersession_for_test(7576, @branch.id, @user )
          }
          it_behaves_like "input particular narration", 2

          it_behaves_like "add particular", 2

          it "creates payment voucher", js: true do
            voucher_form_submit
            expect(page).to have_content("Voucher Details")
            expect(page).to have_content("Voucher was successfully created.")
            # contain company info
            company_info
            # show voucher
            expect(page).to have_content("Payment voucher Bank")
            expect(page).to have_content("Voucher Number: PVB")
            expect(page).to have_content("Voucher Date:")
            expect(page).to have_content("Cr Account Name:")
            expect(page).to have_content("Account Head")
            expect(page).to have_content("Particular")
            expect(page).to have_content("Cheque Number")
            # show details
            expect(page).to have_content("Total Amount")
            expect(page.first('div#particular').text).to eq("description for particular")
            expect(page.first('div#cheque_number').text).to eq("1111")
            expect(page.first('div#total_amount').text).to eq("4,000.00")
            # show details of user activity
            user_activity
            expect(page).to have_content('Approve')
            click_on 'Approve'
            expect(page).to have_content('Payment Voucher was successfully approved')
            #for settlements
            visit settlements_path
            expect(page).to have_content("Settlements")
            select_helper(@client_account.name,"client_accounts_index_combobox" )
            click_on "Search"
            expect(page).to have_content('Subash Adhikari')
            expect(page).to have_content('Show')
            # click_on "Show"
            # expect(page).to have_content('Settlement Details')
          end
        end
      end

      context "when journal voucher" do
        before do
          @client_account1 = create(:client_account, name: "Sushma Adhikari")
          @client_account2 = create(:client_account, name: "Subash aryal")
          visit new_voucher_path
        end

        context "and valid date for fy" do
          let(:setup_spec) {
            UserSession.set_usersession_for_test(7576, @branch.id, @user )
          }
          it_behaves_like "input particular narration"

          it_behaves_like "add particular"

          it "creates journal voucher", js: true do
            select_helper(@client_account1.name, "voucher_particulars_attributes_0_ledger_id")
            fill_in "voucher_particulars_attributes_0_amount", with: 500
            select "dr", :from => "voucher_particulars_attributes_0_transaction_type"
            page.find(".narration-display").click
            fill_in "voucher_particulars_attributes_0_description", with: "debit particular description"
            click_on ('Add Particular')

            page.execute_script(%Q($('div.voucher .box-body > div:nth-child(3) .row.particular > div:nth-child(1) select.form-control').select2('open')))
            page.execute_script(%Q($(".select2-search__field").val('#{@client_account2.name}')))
            page.execute_script(%Q($(".select2-search__field").trigger('keyup')))
            sleep(1)
            # wait_until_page_has_selector('.select2-results__option--highlighted')
            page.execute_script(%Q($('.select2-results__option--highlighted').trigger('mouseup')))

            # particular amount
            find("div.voucher .box-body > div:nth-child(3) .row.particular > div:nth-child(2) div.voucher_particulars_amount input.form-control").set 500
            options = page.all('div.voucher .box-body > div:nth-child(3) .row.particular > div:nth-child(3) select option')
            # to select the last one
            options[-1].select_option
            page.find(".narration-display").click
            find("div.voucher .box-body > div:nth-child(3) div.particular-narration div.voucher_particulars_description input.string").set "credit particular description"
            fill_in "voucher_desc", with: 'sample test for journal voucher'
            click_on 'Submit'
            expect(page).to have_content("Voucher Details")
            expect(page).to have_content("Voucher was successfully created.")
            # contain company info
            company_info
            # show voucher
            expect(page).to have_content("Voucher Number: JVR")
            expect(page).to have_content("Voucher Date:")
            # show description
            expect(page).to have_content("Description")
            expect(page).to have_content("sample test for journal voucher")
            # show details
            expect(page).to have_content("Ledger Details")
            expect(page).to have_content("Particular")
            expect(page).to have_content("Total")
            expect(page.first('div#particular_description').text).to eq("debit particular description")
            expect(page.first('div#total_dr').text).to eq("500.00")
            expect(page.first('div#total_cr').text).to eq("500.00")
            # show details of user activity
            user_activity
          end
        end
      end

      context "when receipt voucher" do
        before do
          @bank_account = create(:bank_account, branch_id: @branch.id, ledger: create(:ledger, name: "Bank:2"))
          @client_account = create(:client_account, name: "ANITA ADHIKARI", nepse_code: "AN123")
          Ledger.find_or_create_by(name: "Cash")
          @bank = create(:bank, name: "kumari bank")
          visit new_voucher_path(voucher_type: Voucher.voucher_types[:receipt])
        end

        it_behaves_like "invalid fy_code"

        context "and valid date for fy" do
          let(:setup_spec) {
            UserSession.set_usersession_for_test(7576, @branch.id, @user )
          }
          it_behaves_like "input particular narration", 2

          it_behaves_like "add particular for receipt", 2

          it "creates receipt voucher", js: true do
            fill_in "voucher_particulars_attributes_0_amount", with: 5000
            fill_in "voucher_particulars_attributes_0_cheque_number", with: 9999
            select_helper(@bank.name, "voucher_particulars_attributes_0_additional_bank_id")
            select_helper(@client_account.name,"voucher_particulars_attributes_3_ledger_id")
            fill_in "voucher_particulars_attributes_3_amount", with: 5000
            add_narrations = page.all(".narration-display")
            add_narrations[-1].click
            fill_in "voucher_particulars_attributes_3_description", with: "description for credit particular"
            click_on 'Submit'
            # for receipt
            expect(page).to have_content("RECEIPT")
            # contain company info
            company_info
            # show details
            expect(page).to have_content('Receipt No:')
            expect(page).to have_content('Date:')
            expect(page).to have_content('Received with thanks from: ')
            expect(page).to have_content('the sum of ')
            expect(page).to have_content('By Cheque:')
            expect(page).to have_content('Cheque Number:')
            expect(page).to have_content('Bank:')
            expect(page).to have_content('Amount:')
            # show details of user activity
            expect(page).to have_content('Paid By')
            expect(page).to have_content('Received By')
            expect(page).to have_content('Note: Please bring this receipt compulsarily while claiming unpurchase share.')
            # for voucher details
            visit ledgers_path
            expect(page).to have_content("Ledger Name")
            select_helper(@client_account.name,"ledgers_index_combobox" )
            click_on "Search"
            click_on "Show"
            click_on "RCB #{get_fy_code}-1"
            expect(page).to have_content("Voucher details")
            # contain company info
            company_info
            # show details
            expect(page).to have_content('Voucher Number: RCB ')
            expect(page).to have_content('Voucher Date:')
            expect(page).to have_content('Ledger Details')
            expect(page).to have_content('Particular')
            expect(page).to have_content('Total')
            expect(page.all('div#particular_description')[1].text).to eq("description for credit particular")
            expect(page.first('div#total_dr').text).to eq("5,000.00")
            expect(page.first('div#total_cr').text).to eq("5,000.00")
            # show details of user activity
            user_activity
            #for settlements
            visit settlements_path
            expect(page).to have_content("Settlements")
            select_helper(@client_account.name,"client_accounts_index_combobox" )
            click_on "Search"
            expect(page).to have_content('ANITA ADHIKARI')
            expect(page).to have_content('Show')
            # click_on "Show"
            # expect(page).to have_content('Settlement Details')
          end
        end
      end
    end

    context "unsigned user" do
      context "when payment voucher" do
        before do
          visit new_voucher_path(voucher_type: Voucher.voucher_types[:payment])
        end
        it_behaves_like "user not signed in"
      end
      context "when journal voucher" do
        before do
          visit new_voucher_path
        end
        it_behaves_like "user not signed in"
      end
      context "when receipt voucher" do
        before do
          visit new_voucher_path(voucher_type: Voucher.voucher_types[:receipt])
        end
        it_behaves_like "user not signed in"
      end
    end
  end
