class AddIndexToCompanyParameter < ActiveRecord::Migration
  def change
    add_index :company_parameter, :company_code
  end
end
