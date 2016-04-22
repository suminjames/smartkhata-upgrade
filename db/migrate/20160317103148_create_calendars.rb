class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :day, null: false
      t.boolean :is_holiday, default: false
      t.integer :date_type, null: false
      t.text :remarks
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
    end
  end
end
