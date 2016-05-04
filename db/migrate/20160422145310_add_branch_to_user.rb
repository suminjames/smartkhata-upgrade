class AddBranchToUser < ActiveRecord::Migration
  def change
    add_column :users, :branch_id, :integer
  end
end