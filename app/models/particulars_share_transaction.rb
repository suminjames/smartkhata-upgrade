# == Schema Information
#
# Table name: particulars_share_transactions
#
#  particular_id        :integer
#  share_transaction_id :integer
#  association_type     :integer
#

class ParticularsShareTransaction < ApplicationRecord
  # include Auditable
  belongs_to :particular
  belongs_to :share_transaction
  enum association_type: [:on_creation, :on_settlement, :on_payment_by_letter]
end
