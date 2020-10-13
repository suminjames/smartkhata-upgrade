# == Schema Information
#
# Table name: cheque_entry_particular_associations
#
#  id               :integer          not null, primary key
#  association_type :integer
#  cheque_entry_id  :integer
#  particular_id    :integer
#

class ChequeEntryParticularAssociation < ApplicationRecord
  belongs_to :cheque_entry
  belongs_to :particular
  enum association_type: { payment: 0, receipt: 1, reversal: 2 }
end
