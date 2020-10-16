# == Schema Information
#
# Table name: particulars_share_transactions
#
#  particular_id        :integer
#  share_transaction_id :integer
#  association_type     :integer
#

class ParticularsShareTransaction < ApplicationRecord
  include Auditable
  belongs_to :particular
  belongs_to :share_transaction
  enum association_type: { on_creation: 0, on_settlement: 1, on_payment_by_letter: 2 }
end
