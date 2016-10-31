class CreateCommission < ActiveRecord::Migration
  def change
    create_table :commission do |t|
      t.string :un_id
      t.date :effective_date_from
      t.date :effective_date_to
    end
  end
end
