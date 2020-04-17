class CreateChequeEntryParticularAssociations < ActiveRecord::Migration[4.2]
  def change
    create_table :cheque_entry_particular_associations do |t|
      t.integer :association_type
      t.belongs_to :cheque_entry, index: true, foreign_key: true
      t.belongs_to :particular, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
