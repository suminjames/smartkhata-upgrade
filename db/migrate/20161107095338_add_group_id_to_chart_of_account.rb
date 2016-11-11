class AddGroupIdToChartOfAccount < ActiveRecord::Migration
  def change
    add_column :chart_of_account, :group_id, :integer
  end
end
