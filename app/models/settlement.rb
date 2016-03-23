class Settlement < ActiveRecord::Base
  belongs_to :voucher
  enum settlement_type: [ :receipt, :payment]
end
