class CreateOrganisationParameter < ActiveRecord::Migration
  def change
    create_table :organisation_parameter do |t|
      t.string :org_name
      t.string :org_address
      t.string :contact_person
      t.string :broker_no
      t.string :off_tel_no
      t.string :res_tel_no
      t.string :fax
      t.string :mobile
      t.string :max_limit
      t.string :transaction_no
      t.string :job_no
      t.string :cash_deposit
      t.string :bank_guarantee
      t.string :pan_no
      t.string :email
      t.string :org_name_nepali
      t.string :org_logo
    end
  end
end
