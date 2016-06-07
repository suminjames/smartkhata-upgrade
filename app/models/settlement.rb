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

  belongs_to :voucher
  include ::Models::UpdaterWithBranchFycode

  enum settlement_type: [ :receipt, :payment]

  belongs_to :client_account
  belongs_to :vendor_account

  filterrific(
      default_filter_params: { sorted_by: 'name_desc' },
      available_filters: [
          :sorted_by,
          :by_settlement_type,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
      ]
  )

  scope :by_settlement_type, -> (type) { where(:settlement_type => Settlement.settlement_types[type]) }

  scope :by_date, lambda { |date_bs|
    where(:date_bs=> strip_leading_zeroes(date_bs))
  }
  scope :by_date_from, lambda { |date_bs|
    where('date_bs >= ?', strip_leading_zeroes(date_bs))
  }
  scope :by_date_to, lambda { |date_bs|
    where('date_bs <= ?', strip_leading_zeroes(date_bs))
  }

  scope :by_client_id, -> (id) { where(client_account_id: id) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name/
        order("LOWER(settlements.name) #{ direction }")
      when /^amount/
        order("settlements.amount #{ direction }")
      when /^type/
        order("settlements.settlement_type #{ direction }")
      when /^date/
        order("settlements.date_bs #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_settlement_type_select
    [["Receipt","receipt"], ["Payment", "payment"]]
  end

 def self.options_for_client_select
   ClientAccount.all.order(:name)
 end

  # A date_bs taken as input has the form 'YYYY-MM-DD'.
  # In circumstances where there is leading zero in month or day like '2073-02-12' or '2073-10-01', the leading zeroes in month and day must be stripped for filtering purpose.
  # This is because date_bs is a string not Date object in database. The comparison operator therefore like >, <  are doing string comparison.
  def self.strip_leading_zeroes(date_bs)
    if date_bs[5] == '0' && date_bs[8] != '0'
      # Case 'YYYY-0M-DD'
      date_bs[5] = ''
    elsif date_bs[5] == '0' && date_bs[8] == '0'
      # Case 'YYYY-0M-0D'
      date_bs[5] = ''
      date_bs[7] = ''
    elsif date_bs[5] != '0' && date_bs[8] == '0'
      # Case 'YYYY-MM-0D'
      date_bs[8] = ''
    end
    date_bs
  end

end
