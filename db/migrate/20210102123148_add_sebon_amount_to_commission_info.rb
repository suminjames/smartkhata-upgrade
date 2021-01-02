class AddSebonAmountToCommissionInfo < ActiveRecord::Migration
  def change
    add_column :master_setup_commission_infos, :sebo_rate, :float
  end
end
