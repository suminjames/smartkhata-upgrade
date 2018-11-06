require 'rails_helper'

RSpec.describe EmployeeLedgerAssociation, type: :model do
	include_context 'session_setup'

	describe "#delete_previous_associations_for" do
		let(:employee_account){create(:employee_account, user_id: @user.id)}
		subject{EmployeeLedgerAssociation.create(employee_account_id: employee_account.id, ledger_id: create(:ledger).id)}

    it "should destroy all previous associations" do
			subject
			expect { EmployeeLedgerAssociation.delete_previous_associations_for(employee_account.id)}.to change{EmployeeLedgerAssociation.count}.from(1).to(0)
		end
  end

end
