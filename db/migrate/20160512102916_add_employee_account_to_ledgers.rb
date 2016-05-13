class AddEmployeeAccountToLedgers < ActiveRecord::Migration
  def change
    add_reference :ledgers, :employee_account, index: true, foreign_key: true
  end
end
