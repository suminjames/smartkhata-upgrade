# == Schema Information
#
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  cheque_number      :integer
#  additional_bank_id :integer
#  bank_account_id    :integer
#  particular_id      :integer
#  settlement_id      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ChequeEntry < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher

  validates :cheque_number, uniqueness: { scope: :additional_bank_id, message: "should be unique" }
end
