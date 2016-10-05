# == Schema Information
#
# Table name: transaction_messages
#
#  id                :integer          not null, primary key
#  sms_message       :string
#  transaction_date  :date
#  sms_status        :integer          default(0)
#  email_status      :integer          default(0)
#  bill_id           :integer
#  client_account_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :date
#  sent_sms_count    :integer          default(0)
#  sent_email_count  :integer          default(0)
#  remarks_email     :string
#  remarks_sms       :string
#

class TransactionMessage < ActiveRecord::Base
  include Auditable
  extend CustomDateModule

  belongs_to :bill
  belongs_to :client_account

  has_many :share_transactions
  enum sms_status: [:sms_unsent, :sms_queued, :sms_sent]
  enum email_status: [:email_unsent, :email_queued, :email_sent]

  scope :not_cancelled, -> { where(deleted_at: nil) }
  scope :cancelled, -> { where.not(deleted_at: nil) }

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def soft_undelete
    update_attribute(:deleted_at, nil)
  end

  filterrific(
      default_filter_params: { sorted_by: 'id_desc' },
      available_filters: [
          :sorted_by,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
      ]
  )

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    includes(:client_account, :bill).select("client_accounts.*, bills.*").references([:client_accounts, :bills]).where(:transaction_date => date_ad.beginning_of_day..date_ad.end_of_day).order(id: :desc)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('transaction_date >= ?', date_ad.beginning_of_day).order(id: :desc)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('transaction_date <= ?', date_ad.end_of_day).order(id: :desc)
  }

  scope :by_client_id, -> (id) { where(client_account_id: id).order(id: :desc) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("transaction_messages.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.latest_transaction_date
    self.maximum("transaction_date")
  end

  def can_email?
    return self.client_account.email.present?
  end

  def can_sms?
    return self.client_account.messageable_phone_number.present?
  end

  def increase_sent_email_count!
    self.sent_email_count += 1
    self.save
  end

  def increase_sent_sms_count!
    self.sent_sms_count += 1
    self.save
  end

end
