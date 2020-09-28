class CreateMergeRebates < ActiveRecord::Migration[4.2]
  def change
    create_table :merge_rebates do |t|
      t.string :scrip, index: true
      t.date :rebate_start
      t.date :rebate_end

      t.timestamps null: false
    end
  end
end
