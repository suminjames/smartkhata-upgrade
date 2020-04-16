class AddGroupIdToChartOfAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :chart_of_account, :group_id, :integer
  end
end
