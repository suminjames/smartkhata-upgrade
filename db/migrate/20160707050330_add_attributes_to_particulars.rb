class AddAttributesToParticulars < ActiveRecord::Migration[4.2]
  def change
    add_column :particulars, :hide_for_client, :boolean, default: false
  end
end
