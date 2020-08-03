class AddValueDateToParticulars < ActiveRecord::Migration
  def change
    add_column :particulars, :value_date, :date
    
    reversible do |dir|
      dir.up { Particular.update_all('value_date = transaction_date') }
    end
  end
end

