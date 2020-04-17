class AddBranchToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :branch_id, :integer
  end
end
