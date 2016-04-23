class BillVoucherRelation < ActiveRecord::Base
  belongs_to :bill
  belongs_to :voucher
  enum relation_type: [ :on_creation, :on_settlement ]
end
