class AddUniqueIndexToEdisItems < ActiveRecord::Migration
  def change
    remove_index :edis_items, :reference_id
    add_index :edis_items, :reference_id, unique: true
  end
end
