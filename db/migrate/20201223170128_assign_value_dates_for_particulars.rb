class AssignValueDatesForParticulars < ActiveRecord::Migration[4.2]
  def up
    Particular.update_all("value_date = transaction_date")
  end
end
