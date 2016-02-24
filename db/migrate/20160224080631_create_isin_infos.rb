class CreateIsinInfos < ActiveRecord::Migration
  def change
    create_table :isin_infos do |t|
    	t.string :company
    	t.string :isin
    	t.string :sector
    	t.decimal :max , precision: 10, scale: 3, default: 0
    	t.decimal :min , precision: 10, scale: 3, default: 0
    	t.decimal :last_price , precision: 10, scale: 3, default: 0
      t.timestamps null: false
    end
  end
end
