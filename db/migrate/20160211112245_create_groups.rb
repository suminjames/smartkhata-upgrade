class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
    	t.string :name
    	t.integer :parent_id
    	t.integer :report
    	t.integer :sub_report
      t.timestamps null: false
    end
  end
end
