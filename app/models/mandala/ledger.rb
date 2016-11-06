class Mandala::Ledger < ActiveRecord::Base
  self.table_name = "ledger"
  belongs_to :particular
end