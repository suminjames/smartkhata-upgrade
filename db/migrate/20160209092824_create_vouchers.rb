class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
    	t.date :date
    	t.string :date_bs
    	t.string :desc
      t.timestamps null: false
    end
  end
end
