class AddIsinInfoIdToCompanyParameter < ActiveRecord::Migration[4.2]
  def change
    add_column :company_parameter, :isin_info_id, :integer
  end
end
