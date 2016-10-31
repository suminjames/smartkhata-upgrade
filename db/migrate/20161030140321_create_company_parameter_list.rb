class CreateCompanyParameterList < ActiveRecord::Migration
  def change
    create_table :company_parameter_list do |t|
      t.string :company_code
      t.string :share_code
      t.integer :no_of_shares, limit: 8
      t.integer :share_no_from, limit: 8
      t.integer :share_no_to, limit: 8
      t.integer :par_value_share
      t.integer :paid_value_share
    end
  end
end
