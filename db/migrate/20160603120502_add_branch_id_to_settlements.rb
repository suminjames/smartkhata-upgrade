class AddBranchIdToSettlements < ActiveRecord::Migration[4.2]
  def change
    add_column :settlements, :branch_id, :integer, index: true
  end
end
