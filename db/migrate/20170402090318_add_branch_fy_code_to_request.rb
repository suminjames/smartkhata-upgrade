class AddBranchFyCodeToRequest < ActiveRecord::Migration
  def change
    add_column :order_request_details, :branch_id, :integer
    add_column :order_request_details, :fy_code, :integer
  end
end
