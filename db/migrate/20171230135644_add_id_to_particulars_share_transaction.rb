class AddIdToParticularsShareTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :particulars_share_transactions, :id, :primary_key
  end
end
