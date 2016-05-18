class ChequeEntryParticularAssociation < ActiveRecord::Base
  belongs_to :cheque_entry
  belongs_to :particular
  enum association_type: [:payment, :receipt ]
end
