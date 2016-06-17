# == Schema Information
#
# Table name: transaction_messages
#
#  id                :integer          not null, primary key
#  sms_message       :string
#  transaction_date  :date
#  sms_status        :integer          default("0")
#  email_status      :integer          default("0")
#  bill_id           :integer
#  client_account_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :date
#  sent_sms_count    :integer
#  sent_email_count  :integer
#

class TransactionMessage < ActiveRecord::Base
  belongs_to :bill
  belongs_to :client_account

  has_many :share_transactions
  enum sms_status: [:sms_default, :sms_sent]
  enum email_status: [:email_default, :email_sent]

  scope :not_cancelled, -> { where(deleted_at: nil) }
  scope :cancelled, -> { where.not(deleted_at: nil) }

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def soft_undelete
    update_attribute(:deleted_at, nil)
  end
end
