class CreateTaxPara < ActiveRecord::Migration
  def change
    create_table :tax_para do |t|
      t.string :unit_id
      t.string :effective_date_from
      t.string :effective_date_to
      t.string :rate
      t.string :tax_name
    end
  end
end
