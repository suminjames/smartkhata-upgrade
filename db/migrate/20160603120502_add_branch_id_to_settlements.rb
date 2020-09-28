class AddBranchIdToSettlements < ActiveRecord::Migration
  def change
    add_column :settlements, :branch_id, :integer, index: true
  end
end
