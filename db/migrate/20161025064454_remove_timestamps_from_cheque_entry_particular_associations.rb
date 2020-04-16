class RemoveTimestampsFromChequeEntryParticularAssociations < ActiveRecord::Migration[4.2]
  def change
    remove_column :cheque_entry_particular_associations, :created_at, :string
    remove_column :cheque_entry_particular_associations, :updated_at, :string
  end
end
