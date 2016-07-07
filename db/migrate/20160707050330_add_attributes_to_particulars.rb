class AddAttributesToParticulars < ActiveRecord::Migration
  def change
    add_column :particulars, :opening_blnc_org, :decimal, precision: 15, scale: 4, default: 0
    add_column :particulars, :running_blnc_org, :decimal, precision: 15, scale: 4, default: 0
    add_column :particulars, :hide_for_client, :boolean, default: false
    add_column :particulars, :running_blnc_client, :decimal, precision: 15, scale: 4, default: 0
  end
end
