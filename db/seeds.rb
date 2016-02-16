# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

Group.create([
	{ name: "Capital", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']},
	
	{name: "Fixed Assets", report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets']}])

group = Group.create({name: "Reserve & Surplus", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']})
groups = Group.create([
	{ name: "Profit & Loss Account"},
	{name: "General Reserve"},
	{name: "Capital Reserve"},
	{name: "Purchase", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']},
	{name: "Sales", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']},
	{name: "Direct Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']},
	{name: "Indirect Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']}, 
	{ name: "Direct Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']}, 
	{name: "Indirect Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']}
	])

group.children << groups
group.save!

group = Group.create({name: "Loan", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']})
groups = Group.create([{ name: "Secured Loan"},{name: "Unsecured Loan"}])
group.children << groups
group.save!

group = Group.create({name: "Current Liabilities", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']})
groups = Group.create([{ name: "Duties & Taxes"},{name: "Sundry Creditors"},{name: "Account Payables"}])
group.children << groups
group.save!

group = Group.create({name: "Current Assets",report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets']})
groups = Group.create([{ name: "Advances and Receivables"},{name: "Sundry Debtors"},{name: "Account Receivables"}])
group.children << groups
group.save!