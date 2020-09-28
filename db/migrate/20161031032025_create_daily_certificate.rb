class CreateDailyCertificate < ActiveRecord::Migration[4.2]
  def change
    create_table :daily_certificate do |t|
      t.string :transaction_no
      t.string :certificate_no
      t.string :kitta_no_from
      t.string :kitta_no_to
      t.string :share_holder
      t.string :total
      t.string :name_transfer_date
      t.string :name_transfer_receipt_date
      t.string :client_certificate_issue_date
      t.string :fiscal_year
      t.string :transaction_type
    end
  end
end
