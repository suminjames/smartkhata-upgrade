class PrtclrShareTrxnAssocn < ActiveRecord::Base
  belongs_to :particular
  belongs_to :share_transaction
  enum association_type: [:on_creation, :on_settlement, :on_payment_by_letter]
end
