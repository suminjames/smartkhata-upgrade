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



class EmployeeLedgerAssociation < ActiveRecord::Base
  include ::Models::Updater

  belongs_to :employee_account
  belongs_to :ledger

  def self.delete_previous_associations_for(employee_account_id)
    self.destroy_all(employee_account_id: "#{employee_account_id}")
  end
end
