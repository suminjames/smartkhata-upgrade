class CreateEmployeeClientAssociations < ActiveRecord::Migration
  def change
    create_table :employee_client_associations do |t|
      t.references :employee_account, index: true
      t.references :client_account, index:true
      t.timestamps null: false
    end
  end
end
