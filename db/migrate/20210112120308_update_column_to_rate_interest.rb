class UpdateColumnToRateInterest < ActiveRecord::Migration[4.2]
  def change
    change_column :interest_particulars, :rate, :decimal, :precision => 4, :scale => 2
  end
end
