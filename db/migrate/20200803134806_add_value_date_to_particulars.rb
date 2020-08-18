class AddValueDateToParticulars < ActiveRecord::Migration
  def change
    add_column :particulars, :value_date, :date
  end
end

