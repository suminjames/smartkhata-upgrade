require 'test_helper'
require "#{Rails.root}/app/globalhelpers/custom_date_module"

class FloorsheetFlowTest < ActionDispatch::IntegrationTest
  include CustomDateModule
  def setup
    set_host
    log_in
    set_fy_code_and_branch

    # Create groups: from seeds.rb
    Group.create!([
                     { name: "Capital", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true},
                     {name: "Fixed Assets", report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true}])

    group = Group.create({name: "Reserve & Surplus", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']})
    groups = Group.create([
                              { name: "Profit & Loss Account", for_trial_balance: true},
                              {name: "General Reserve"},
                              {name: "Capital Reserve"},
                              # {name: "Purchase", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']},
                              # {name: "Sales", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']},
                              {name: "Direct Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                              {name: "Indirect Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                              { name: "Direct Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true},
                              {name: "Indirect Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true}
                          ])

    group.children << groups
    group.save!

    group = Group.find_by(name: "Direct Income")
    ledgers = Ledger.create([{name: "Purchase Commission"},{name: "Sales Commission"}])
    group.ledgers << ledgers
    group.save!

    group = Group.create({name: "Loan", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true})
    groups = Group.create([{ name: "Secured Loan"},{name: "Unsecured Loan"}])
    group.children << groups
    group.save!

    group = Group.create({name: "Current Liabilities", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true})
    groups = Group.create([{ name: "Duties & Taxes"},{name: "Sundry Creditors"},{name: "Account Payables"}])
    ledgers = Ledger.create([{name: "DP Fee/ Transfer"}, {name: "Nepse Purchase"}, {name: "Nepse Sales"}, {name: "Clearing Account"}, {name: 'Compliance Fee'}])
    group.children << groups
    group.ledgers << ledgers
    group.save!

    group = Group.find_by(name: "Current Assets")
    group.update({report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true})
    groups = Group.create([{ name: "Advances and Receivables"},{name: "Sundry Debtors"},{name: "Account Receivables"}, {name: "Clients"}, {name: "Clearing Account"}])
    group.children << groups
    ledgers = Ledger.create([{name: "TDS"},{name: "Cash"},{name: 'Close Out'}])
    group.ledgers << ledgers
    group.save!

    @get_opening_balance_diff = lambda {
      get report_balancesheet_index_path
      assigns(:opening_balance_diff)
    }
  end

  test "floorsheet flow" do
    initial_opening_balance_diff = @get_opening_balance_diff
    assert_difference 'FileUpload.where(file_type: FileUpload::file_types[:floorsheet]).count', 1 do
      file = fixture_file_upload(Rails.root.join('test/fixtures/files/May12/BrokerwiseFloorSheetReport 12 May.xls'), 'text/xls')
      post import_files_floorsheets_path, file: file
    end
    final_opening_balance_diff = @get_opening_balance_diff

    # 1. CHECK BALANCE SHEET
    assert_equal initial_opening_balance_diff, final_opening_balance_diff

    # 2. CHECK TRIAL BALANCE
    date_bs = ad_to_bs (Date.parse '2016-05-12') #floorsheet date
    get report_trial_balance_index_path(search_by:'date', search_term: date_bs)

    # scrape to find total: in the application, this is done by jquery
    ledger_rows = css_select('.ledger-group .ledger-single')
    opening_balance_dr = opening_balance_cr = dr_amount = cr_amount = closing_balance_dr = closing_balance_cr = 0
    ledger_rows.each do |row|
      #array of data # e.element? also possibly works
      data = row.children.select{|e| e.name=="td" }
      #remove commas and convert to numbers
      data.map!{|x| x.text.gsub(',','').to_f} #to_f

      opening_balance_dr += data[1]
      opening_balance_cr += data[2]
      dr_amount += data[3]
      cr_amount += data[4]
      closing_balance_dr += data[5]
      closing_balance_cr += data[6]
    end

    # Credits and debits in the grand total row should be equal
    [ [opening_balance_dr, opening_balance_cr],
      [dr_amount, cr_amount],
      [closing_balance_dr, closing_balance_cr] ].each { |a, b| assert_equal a.to_i, b.to_i }

    # Check the amounts and closing balance are greater than zero
    [dr_amount, closing_balance_cr].each { |v| assert_operator v, :>, 0 }


  end
end