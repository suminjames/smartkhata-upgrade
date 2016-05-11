# == Schema Information
#
# Table name: bill_voucher_relations
#
#  id            :integer          not null, primary key
#  relation_type :integer
#  bill_id       :integer
#  voucher_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class BillVoucherRelation < ActiveRecord::Base
  belongs_to :bill
  belongs_to :voucher
  enum relation_type: [ :on_creation, :on_settlement ]
end
