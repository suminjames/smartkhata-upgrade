# == Schema Information
#
# Table name: particular_settlement_associations
#
#  association_type :integer          default(0)
#  particular_id    :integer
#  settlement_id    :integer
#

class ParticularSettlementAssociation < ApplicationRecord
  belongs_to :particular
  belongs_to :settlement
  enum association_type: { dr: 0, cr: 1 }
end
