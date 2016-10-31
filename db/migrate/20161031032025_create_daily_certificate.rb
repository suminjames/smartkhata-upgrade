class CreateDailyCertificate < ActiveRecord::Migration
  def change
    create_table :daily_certificate do |t|
      t.integer :transaction_no, limit: 8
      t.integer :certificate_no, limit: 8
      t.integer :kitta_no_from, limit: 8
      t.integer :kitta_no_to, limit: 8
      t.string :share_holder
      t.integer :total, limit: 8
      t.date :name_transfer_date
      t.date :name_transfer_receipt_date
      t.date :client_certificate_issue_date
      t.string :fiscal_year
      t.string :transaction_type
    end
  end
end
