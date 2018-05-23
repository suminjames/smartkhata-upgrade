class AddedRestrictedToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :restricted, :boolean, default: false
  end
end
