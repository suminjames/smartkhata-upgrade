class AddIndexToCompanyParameter < ActiveRecord::Migration[4.2]
  def change
    add_index :company_parameter, :company_code
  end
end
