class CreateCapitalGainDetail < ActiveRecord::Migration
  def change
    create_table :capital_gain_detail do |t|
      t.string :group_code
      t.integer :capital_gain_pct
      t.date :effective_from
      t.date :effective_to
    end
  end
end
