class SalesSettlement < ActiveRecord::Base
  belongs_to :share_transaction
  belongs_to :nepse_provisional_settlement
  has_many :edis_items
end
