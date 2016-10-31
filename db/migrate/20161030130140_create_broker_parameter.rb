class CreateBrokerParameter < ActiveRecord::Migration
  def change
    create_table :broker_parameter do |t|
      t.string :org_name
      t.string :org_address
      t.string :contact_person
      t.integer :broker_no
      t.string :off_tel_no
      t.string :res_tel_no
      t.string :fax
      t.string :mobile
    end
  end
end
