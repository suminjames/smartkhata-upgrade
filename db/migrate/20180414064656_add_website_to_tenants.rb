class AddWebsiteToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :website, :string
  end
end
