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
#

class TransactionMessage < ActiveRecord::Base
  belongs_to :bill
  belongs_to :client_account

  enum sms_status: [:sms_default, :sms_sent]
  enum email_status: [:email_default, :email_sent]

  filterrific(
      default_filter_params: { sorted_by: 'date_desc' },
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
    where(:transaction_date=> date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('transaction_date >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('transaction_date <= ?', date_ad.end_of_day)
  }

  scope :by_client_id, -> (id) { where(client_account_id: id) }
  
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^date/
        order("transaction_messages.transaction_date #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_client_select
    ClientAccount.all.order(:name)
  end

end
