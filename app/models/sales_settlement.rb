class SalesSettlement < ActiveRecord::Base
  enum status: [:pending, :complete]
end
