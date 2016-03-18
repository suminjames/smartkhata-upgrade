class Receipt < ActiveRecord::Base
  #TODO Saroj will scold for this
  enum receipt_type: [ :receipt, :payment ]
end
