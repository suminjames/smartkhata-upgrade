class AddBranchIdToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :branch_id, :integer, index: true
    add_column :bank_accounts, :bank_branch, :string
    add_column :bank_accounts, :address, :text
    add_column :bank_accounts, :contact_no, :string
  end
end
