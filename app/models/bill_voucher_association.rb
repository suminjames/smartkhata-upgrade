# == Schema Information
#
# Table name: bill_voucher_associations
#
#  id               :integer          not null, primary key
#  association_type :integer
#  bill_id          :integer
#  voucher_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class BillVoucherAssociation < ActiveRecord::Base
  belongs_to :bill
  belongs_to :voucher
  enum association_type: [:on_creation, :on_settlement ]
end
