class RemoveTimestampsFromParticularSettlementAssociations < ActiveRecord::Migration
  def change
    remove_column :particular_settlement_associations, :created_at, :string
    remove_column :particular_settlement_associations, :updated_at, :string
  end
end
