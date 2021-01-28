class AddSebonAmountToCommissionInfo < ActiveRecord::Migration[4.2]
  def change
    add_column :master_setup_commission_infos, :sebo_rate, :float
  end
end
