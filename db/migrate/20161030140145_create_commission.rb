class CreateCommission < ActiveRecord::Migration
  def change
    create_table :commission do |t|
      t.string :un_id
      t.string :effective_date_from
      t.string :effective_date_to
    end
  end
end
