class AddUniqueIndexToEdisItems < ActiveRecord::Migration[4.2]
  def change
    remove_index :edis_items, :reference_id
    add_index :edis_items, :reference_id, unique: true
  end
end
