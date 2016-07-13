class AddAttributesToParticulars < ActiveRecord::Migration
  def change
    add_column :particulars, :hide_for_client, :boolean, default: false
  end
end