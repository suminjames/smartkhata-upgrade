class CreateShareInventories < ActiveRecord::Migration[4.2]
  def change
    create_table :share_inventories do |t|
      t.string :isin_desc
      t.decimal :current_blnc , precision: 10, scale: 3, default: 0
      t.decimal :free_blnc , precision: 10, scale: 3, default: 0
      t.decimal :freeze_blnc , precision: 10, scale: 3, default: 0
      t.decimal :dmt_pending_veri , precision: 10, scale: 3, default: 0
      t.decimal :dmt_pending_conf , precision: 10, scale: 3, default: 0
      t.decimal :rmt_pending_conf , precision: 10, scale: 3, default: 0
      t.decimal :safe_keep_blnc , precision: 10, scale: 3, default: 0
      t.decimal :lock_blnc , precision: 10, scale: 3, default: 0
      t.decimal :earmark_blnc , precision: 10, scale: 3, default: 0
      t.decimal :elimination_blnc , precision: 10, scale: 3, default: 0
      t.decimal :avl_lend_blnc , precision: 10, scale: 3, default: 0
      t.decimal :lend_blnc , precision: 10, scale: 3, default: 0
      t.decimal :borrow_blnc , precision: 10, scale: 3, default: 0
      t.decimal :pledge_blnc , precision: 10, scale: 3, default: 0

      t.decimal :total_in, precision: 10, scale: 0, default: 0
      t.decimal :total_out, precision: 10, scale: 0, default: 0
      t.decimal :floorsheet_blnc , precision: 10, scale: 0, default: 0

      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.integer :branch_id, index: true
      t.date :report_date
      t.references :client_account, index: true
      t.references :isin_info, index: true
      t.timestamps null: false
    end
  end
end
