class AddValueDateToParticulars < ActiveRecord::Migration[4.2]
  def change
    add_column :particulars, :value_date, :date
  end
end

