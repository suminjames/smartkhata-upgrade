class CreateCapitalGainDetail < ActiveRecord::Migration[4.2]
  def change
    create_table :capital_gain_detail do |t|
      t.string :group_code
      t.string :capital_gain_pct
      t.string :effective_from
      t.string :effective_to
    end
  end
end
