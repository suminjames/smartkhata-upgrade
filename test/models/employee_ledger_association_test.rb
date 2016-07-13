# == Schema Information
#
# Table name: employee_ledger_associations
#
#  id                  :integer          not null, primary key
#  employee_account_id :integer
#  ledger_id           :integer
#  creator_id          :integer
#  updater_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class EmployeeLedgerAssociationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
