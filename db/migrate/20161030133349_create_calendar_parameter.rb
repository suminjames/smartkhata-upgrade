class CreateCalendarParameter < ActiveRecord::Migration[4.2]
  def change
    create_table :calendar_parameter do |t|
      t.string :ad_date
      t.string :bs_date
      t.string :holiday_tag
      t.string :day
    end
  end
end
