class ChangeBrokerNumberTypeBrokerProfile < ActiveRecord::Migration
  def change
    change_column :broker_profiles, :broker_number,'integer USING CAST(broker_number AS integer)'
  end
end
