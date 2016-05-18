# == Schema Information
#
# Table name: sales_settlements
#
#  id              :integer          not null, primary key
#  settlement_id   :decimal(18, )
#  status          :integer          default("0")
#  creator_id      :integer
#  updater_id      :integer
#  settlement_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class SalesSettlement < ActiveRecord::Base
  enum status: [:pending, :complete]
  include ::Models::Updater

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
end
