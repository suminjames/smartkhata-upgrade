class ChangeWaccFieldInEdisItems < ActiveRecord::Migration
  def change
    change_column :edis_items, :wacc, :decimal, :precision => 12, :scale => 2
  end
end
