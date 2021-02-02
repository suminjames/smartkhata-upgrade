require 'rails_helper'

RSpec.describe EmployeeLedgerAssociation, type: :model do
	include_context 'session_setup'
	
	describe "#delete_previous_associations_for" do
		let(:employee_account) { create(:employee_account, branch_id: branch.id) }
		let(:branch) { create(:branch) }
    let(:ledger){ create(:ledger) }
    let(:user){ create(:user) }
		subject { EmployeeLedgerAssociation.new(employee_account: employee_account, ledger: ledger) }

    it "should destroy all previous associations" do
      subject.save
			expect { EmployeeLedgerAssociation.delete_previous_associations_for(employee_account.id) }.to change { EmployeeLedgerAssociation.count }.from(1).to(0)
		end
	end
end
