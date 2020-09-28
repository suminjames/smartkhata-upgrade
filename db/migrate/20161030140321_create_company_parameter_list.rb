class CreateCompanyParameterList < ActiveRecord::Migration
  def change
    create_table :company_parameter_list do |t|
      t.string :company_code
      t.string :share_code
      t.string :no_of_shares
      t.string :share_no_from
      t.string :share_no_to
      t.string :par_value_share
      t.string :paid_value_share
    end
  end
end
