class ChangeBrokerNumberTypeBrokerProfile < ActiveRecord::Migration[4.2]
  def change
    change_column :broker_profiles, :broker_number,'integer USING CAST(broker_number AS integer)'
  end
end
