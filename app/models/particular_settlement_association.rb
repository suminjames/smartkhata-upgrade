
class ParticularSettlementAssociation < ActiveRecord::Base
  belongs_to :particular
  belongs_to :settlement
  enum association_type: [:dr, :cr]
end
