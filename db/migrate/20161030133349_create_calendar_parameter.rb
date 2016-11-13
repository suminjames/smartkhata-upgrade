class CreateCalendarParameter < ActiveRecord::Migration
  def change
    create_table :calendar_parameter do |t|
      t.string :ad_date
      t.string :bs_date
      t.string :holiday_tag
      t.string :day
    end
  end
end
