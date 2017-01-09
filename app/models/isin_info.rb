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

  # The 'skip_company_validation' flag is true while importing floorsheet file.
  attr_accessor :skip_company_validation

  validates_presence_of :company, :if => lambda{|record| !record.skip_company_validation }
  validates :isin, uniqueness: true, presence: true, :case_sensitive => false

  # Used by combobox in view
  # In rare circumstances, the data crawled from nepse's site has (apparently errorenous) numeric(eg: 001) value as isin code for a company. This method makes it easier to identify a company in these cases.
  def name_and_code
    "#{self.isin} (#{self.company})"
  end

  def find_or_create_new_by_symbol(symbol)
    company_info = IsinInfo.find_by_isin(company_symbol)
    unless company_info.present?
      new_isin_info = IsinInfo.new
      new_isin_info.skip_company_validation = true
      new_isin_info.isin = company_symbol
      new_isin_info.save!
    end
    new_isin_info
  end
end
