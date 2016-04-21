# == Schema Information
#
# Table name: settlements
#
#  id                :integer          not null, primary key
#  name              :string
#  amount            :decimal(, )
#  date_bs           :string
#  description       :string
#  settlement_type   :integer
#  fy_code           :integer
#  settlement_number :integer
#  voucher_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Settlement < ActiveRecord::Base
  belongs_to :voucher
  enum settlement_type: [ :receipt, :payment]
end
