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
#  client_account_id :integer
#  vendor_account_id :integer
#  creator_id        :integer
#  updater_id        :integer
#  receiver_name     :string
#  voucher_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  branch_id         :integer
#

class Settlement < ActiveRecord::Base

  belongs_to :voucher
  include ::Models::UpdaterWithBranchFycode

  enum settlement_type: [ :receipt, :payment]

  belongs_to :client_account
  belongs_to :vendor_account

  scope :by_settlement_type, -> (type) { where(:settlement_type => Settlement.settlement_types[type]) }
  scope :by_date, -> (date) { where(:created_at => date.beginning_of_day..date.end_of_day) }
  scope :by_date_range, -> (date_from, date_to) { where( :date => date_from.beginning_of_day..date_to.end_of_day) }
  scope :by_client_id, -> (id) { where(client_account_id: id) }
  scope :by_vendor_id, -> (id) { where(vendor_account_id: id) }
end
