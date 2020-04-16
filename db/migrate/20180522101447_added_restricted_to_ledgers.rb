class AddedRestrictedToLedgers < ActiveRecord::Migration[4.2]
  def change
    add_column :ledgers, :restricted, :boolean, default: false
  end
end
