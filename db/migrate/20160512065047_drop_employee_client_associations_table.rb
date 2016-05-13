class DropEmployeeClientAssociationsTable < ActiveRecord::Migration
  def up
    drop_table :employee_client_associations
  end
end
