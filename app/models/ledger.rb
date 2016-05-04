# == Schema Information
#
# Table name: ledgers
#
#  id                :integer          not null, primary key
#  name              :string
#  client_code       :string
#  opening_blnc      :decimal(15, 4)   default("0.0")
#  closing_blnc      :decimal(15, 4)   default("0.0")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :integer
#  bank_account_id   :integer
#  client_account_id :integer
#  dr_amount         :decimal(15, 4)   default("0.0"), not null
#  cr_amount         :decimal(15, 4)   default("0.0"), not null
#


class Ledger < ActiveRecord::Base
end
