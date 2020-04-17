class CreateCapitalGainPara < ActiveRecord::Migration[4.2]
  def change
    create_table :capital_gain_para do |t|
      t.string :group_code
      t.string :group_name
      t.string :remarks
    end
  end
end
