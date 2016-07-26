# == Schema Information
#
# Table name: settlements
#
#  id                :integer          not null, primary key
#  name              :string
#  amount            :decimal(, )
#  date_bs           :string
#  description       :string
#  settlement_type   :integer
#  fy_code           :integer
#  settlement_number :integer
#  client_account_id :integer
#  vendor_account_id :integer
#  creator_id        :integer
#  updater_id        :integer
#  receiver_name     :string
#  voucher_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  branch_id         :integer
#


class Settlement < ActiveRecord::Base
  extend CustomDateModule

  default_scope {where(fy_code: UserSession.selected_fy_code)}


  belongs_to :voucher
  include ::Models::UpdaterWithBranchFycode

  enum settlement_type: [:receipt, :payment]

  belongs_to :client_account
  belongs_to :vendor_account

  filterrific(
      default_filter_params: {sorted_by: 'name_desc'},
      available_filters: [
          :sorted_by,
          :by_settlement_type,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id
      ]
  )

  scope :by_settlement_type, -> (type) { by_branch_fy_code.where(:settlement_type => Settlement.settlement_types[type]) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    by_branch_fy_code.where(:created_at => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    by_branch_fy_code.where('created_at >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    by_branch_fy_code.where('created_at <= ?', date_ad.end_of_day)
  }

  scope :by_client_id, -> (id) { by_branch_fy_code.where(client_account_id: id) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name/
        by_branch_fy_code.order("LOWER(settlements.name) #{ direction }")
      when /^amount/
        by_branch_fy_code.order("settlements.amount #{ direction }")
      when /^type/
        by_branch_fy_code.order("settlements.settlement_type #{ direction }")
      when /^date/
        by_branch_fy_code.order("settlements.date_bs #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  before_create :assign_settlement_number

  def self.options_for_settlement_type_select
    [["Receipt", "receipt"], ["Payment", "payment"]]
  end

  def self.options_for_client_select
    ClientAccount.all.order(:name)
  end

  #
  # get new settlement number
  #
  def self.new_settlement_number(fy_code, branch_id, settlement_type)
    settlement_type = self.settlement_types[settlement_type]
    settlement = Settlement.where(fy_code: fy_code, branch_id: branch_id, settlement_type: settlement_type).last
    if settlement.nil?
      1
    else
      # increment the bill number
      settlement.settlement_number + 1
    end
  end

  def assign_settlement_number
    fy_code = self.fy_code
    branch_id = self.branch_id
    settlement_type = self.settlement_type
    self.settlement_number = Settlement.new_settlement_number(fy_code, branch_id, settlement_type)
  end
end
