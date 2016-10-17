# == Schema Information
#
# Table name: particular_settlement_associations
#
#  association_type :integer
#  particular_id    :integer
#  settlement_id    :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class ParticularSettlementAssociation < ActiveRecord::Base
  belongs_to :particular
  belongs_to :settlement
  enum association_type: [:dr, :cr]
end
