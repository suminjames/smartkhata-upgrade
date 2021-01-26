# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :float
#  rate          :integer
#  date          :date
#  interest_type :integer
#  ledger_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class InterestParticular < ActiveRecord::Base
  extend FiscalYearModule
  extend CustomDateModule
  include CustomDateModule

  belongs_to :ledger
  delegate :client_account, :to => :ledger, :allow_nil => true
  before_save :process_particular
  enum interest_type: %i[dr cr]

  filterrific(
    default_filter_params: { },
    available_filters: [
      :sorted_by,
      :by_client_id,
      :by_interest_type,
      :by_date,
      :by_date_from,
      :by_date_to
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("interest_particulars.id #{ direction }")
      when /^date/
        order("interest_particulars.date #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_client, -> { joins(ledger: :client_account).select("interest_particulars.*, client_accounts.name as client")}

  scope :by_client_id, -> (id) { with_client.where(client_accounts: { id: id }) }

  scope :by_interest_type, -> (type) { where(interest_type: interest_types[:"#{type}"]) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:date => date_ad.beginning_of_day..date_ad.end_of_day)
  }

  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('interest_particulars.date >= ?', date_ad.beginning_of_day)
  }

  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('interest_particulars.date <= ?', date_ad.end_of_day)
  }

  def self.option_for_interest_type_select
    InterestParticular.interest_types.map { |v, i| [v.upcase, v] }
  end

  def self.calculate_interest(date: Date.yesterday, ledger_id: nil, payable_interest_rate: nil, receivable_interest_rate: nil)
    interest_particulars = []

    fy_code = get_fy_code(date)

    if ledger_id.present?
      ledgers = Ledger.where(id: [ledger_id]).select(:id)
    else
      ledgers = Ledger
        .find_all_client_ledgers
        .where( id: Particular.where(fy_code: fy_code).distinct(:ledger_id).select(:ledger_id)).select(:id)
    end
    payable_interest_rate ||= InterestRate.get_rate(date, :payable)
    receivable_interest_rate ||= InterestRate.get_rate(date, :receivable)

    ledgers.find_each do |ledger|
      ledger_id = ledger.id

      balance = LedgerBalance.by_branch_fy_code(0,fy_code).where(ledger_id: ledger_id).first
      opening_principal = balance.dr? ? balance.opening_balance : balance.opening_balance * -1

      interest_calculable_data = InterestCalculationService.new(ledger_id, date, opening_principal, payable_interest_rate, receivable_interest_rate).call
      if interest_calculable_data
        InterestParticular
          .find_or_initialize_by(date: date, ledger_id: ledger_id)
          .update(
            {
              interest: interest_calculable_data[:interest],
              amount: interest_calculable_data[:amount],
              rate: interest_calculable_data[:interest_attributes][:value],
              date_bs: ad_to_bs_string(date),
              interest_type: interest_calculable_data[:interest_attributes][:type],
            }
          )
      end
    end
  end


  def process_particular
    self.date_bs ||= ad_to_bs_string(self.date)
  end
end
