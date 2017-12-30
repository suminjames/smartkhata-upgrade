class AddIdToParticularsShareTransaction < ActiveRecord::Migration
  def change
    add_column :particulars_share_transactions, :id, :primary_key
  end
end
