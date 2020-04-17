class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
    	t.string :name
    	t.integer :parent_id
    	t.integer :report
    	t.integer :sub_report
      t.boolean :for_trial_balance, default: false
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.timestamps null: false
    end
  end
end
