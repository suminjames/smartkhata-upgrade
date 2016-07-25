# == Schema Information
#
# Table name: public.isin_infos
#
#  id         :integer          not null, primary key
#  company    :string
#  isin       :string
#  sector     :string
#  max        :decimal(10, 4)   default(0.0)
#  min        :decimal(10, 4)   default(0.0)
#  last_price :decimal(10, 4)   default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IsinInfo < ActiveRecord::Base
  has_many :share_transactions

  # Used by combobox in view
  # In rare circumstances, the data crawled from nepse's site has (apparently errorenous) numeric(eg: 001) value as isin code for a company. This method makes it easier to identify a company in these cases.
  def name_and_code
    "#{self.isin} (#{self.company})"
  end
end
