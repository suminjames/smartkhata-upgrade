class AddWebsiteToTenants < ActiveRecord::Migration[4.2]
  def change
    add_column :tenants, :website, :string
  end
end
