class CreateTaxPara < ActiveRecord::Migration
  def change
    create_table :tax_para do |t|
      t.string :unit_id
      t.date :effective_date_from
      t.date :effective_date_to
      t.decimal :rate, precision: 15, scale: 4
      t.string :tax_name
    end
  end
end
