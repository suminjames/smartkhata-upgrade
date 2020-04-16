class CreateCommission < ActiveRecord::Migration[4.2]
  def change
    create_table :commission do |t|
      t.string :un_id
      t.string :effective_date_from
      t.string :effective_date_to
    end
  end
end
