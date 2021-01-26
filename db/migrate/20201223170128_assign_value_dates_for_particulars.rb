class AssignValueDatesForParticulars < ActiveRecord::Migration
  def up
    Particular.update_all("value_date = transaction_date")
  end
end
