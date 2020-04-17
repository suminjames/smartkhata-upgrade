# == Schema Information
#
# Table name: daily_transaction_no
#
#  id             :integer          not null, primary key
#  transaction_no :string
#  fiscal_year    :string
#

class Mandala::DailyTransactionNo < ApplicationRecord
  self.table_name = "daily_transaction_no"
end
