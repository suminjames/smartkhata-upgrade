class AddColumnToEdisItems < ActiveRecord::Migration[4.2]
  def change
    add_column :edis_items, :status_message, :text
  end
end
