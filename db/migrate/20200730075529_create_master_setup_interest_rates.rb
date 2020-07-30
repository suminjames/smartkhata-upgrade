class CreateMasterSetupInterestRates < ActiveRecord::Migration
  def change
    create_table :master_setup_interest_rates do |t|
      t.date :start_date
      t.date :end_date
      t.integer :interest_type
      t.integer :rate

      t.timestamps null: false
    end
  end
end
