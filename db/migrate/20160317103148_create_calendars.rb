class CreateCalendars < ActiveRecord::Migration[4.2]
  def change
    create_table :calendars do |t|
      t.text :bs_date, null: false  # should be of format yyyy-mm-dd
      t.date :ad_date, null: false
      t.boolean :is_holiday, default: false
      t.boolean :is_trading_day, default: true
      t.integer :holiday_type, default: 0
      t.text :remarks
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
    end
  end
end
