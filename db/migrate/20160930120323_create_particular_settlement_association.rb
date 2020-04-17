class CreateParticularSettlementAssociation < ActiveRecord::Migration[4.2]
  def change
    create_table :particular_settlement_associations, :id => false  do |t|
      t.integer :association_type, default: 0
      t.belongs_to :particular, index: true, foreign_key: true
      t.belongs_to :settlement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
