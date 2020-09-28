class AddColumnToEdisItems < ActiveRecord::Migration
  def change
    add_column :edis_items, :status_message, :text
  end
end
