class AddIsinInfoIdToCompanyParameter < ActiveRecord::Migration
  def change
    add_column :company_parameter, :isin_info_id, :integer
  end
end
