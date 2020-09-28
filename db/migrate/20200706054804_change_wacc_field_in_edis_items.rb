class ChangeWaccFieldInEdisItems < ActiveRecord::Migration[4.2]
  def change
    change_column :edis_items, :wacc, :decimal, :precision => 12, :scale => 2
  end
end
