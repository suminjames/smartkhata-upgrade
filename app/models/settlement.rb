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
#  creator_id        :integer
#  updater_id        :integer
#  receiver_name     :string
#  voucher_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#


class Settlement < ActiveRecord::Base
  belongs_to :voucher
  include ::Models::Updater
  enum settlement_type: [ :receipt, :payment]
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
end
