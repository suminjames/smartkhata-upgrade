class AddDateToSettlements < ActiveRecord::Migration
  extend CustomDateModule

  def up
    add_column :settlements, :date, :date
  end

  def down
    remove_column :settlements, :date
  end
end
