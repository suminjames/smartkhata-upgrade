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

class IsinInfo < ApplicationRecord
  has_many :share_transactions

  # The 'skip_company_validation' flag is true while importing floorsheet file.
  attr_accessor :skip_company_validation

  validates_presence_of :company, :if => lambda{|record| !record.skip_company_validation }
  validates_presence_of :isin, :sector
  validates_uniqueness_of :isin, :case_sensitive => false
  has_many :order_request_details

  scope :by_isin_info_id, ->(isin_info_id) { where(id: isin_info_id) }
  scope :by_sector, ->(sector_string) { where("sector": sector_string) }
  scope :by_isin, ->(isin) { where(isin: isin) }

  filterrific(
      default_filter_params: { },
      available_filters: [
          :by_isin_info_id,
          :by_sector,
          :by_isin
      ]
  )

  def commission_group
    return :debenture if sector == 'Corporate Debenture'
    return :mutual_funds if sector == 'Mutual Fund'
    :regular
  end

  # Used by combobox in view
  # In rare circumstances, the data crawled from nepse's site has (apparently errorenous) numeric(eg: 001) value as isin code for a company. This method makes it easier to identify a company in these cases.
  def name_and_code(opts={})
    if opts[:line_break] == true
      _str =  self.company.present? ? "#{self.isin}\n(#{self.company})" : "#{self.isin}"
      if opts[:html_safe] == true
        _str = _str.gsub("\n", "<br>").html_safe
      end
    else
      _str = self.company.present? ? "#{self.isin} (#{self.company})" : "#{self.isin}"
    end
    _str
  end

  def self.options_for_isin_info_select(filterrific_params)
    isin_info_arr = []
    if filterrific_params.present? && filterrific_params[:by_isin_info_id].present?
      isin_info_id = filterrific_params[:by_isin_info_id]
      isin_info_arr = self.by_isin_info_id(isin_info_id)
    end
    isin_info_arr
  end

  def self.options_for_sector_select
    options = []
    IsinInfo.select('DISTINCT sector').each do |isin_info|
      if isin_info.sector.present?
        options << [isin_info.sector] * 2
      end
    end
    options
  end

  def self.find_similar_to_term(search_term, isin_only = false)
    search_term = search_term.present? ? search_term.to_s : ''
    isin_infos = IsinInfo.where("company ILIKE :search OR isin ILIKE :search", search: "%#{search_term}%").order(:isin).pluck_to_hash(:id, :company, :isin)
    isin_infos.collect do |isin_info|
      if isin_only
        isin_info
      else
        identifier = "#{isin_info['isin']}"
        if isin_info['company'].present?
          identifier += " (#{isin_info['company']})"
        end
        { :text=> identifier, :id => isin_info['id'].to_s }
      end
    end
  end

  def self.find_or_create_new_by_symbol(company_symbol)
    # company_info = IsinInfo.find_by_isin(company_symbol)
    company_info = IsinInfo.where('isin ilike ?', company_symbol).first
    unless company_info.present?
      new_isin_info = IsinInfo.new
      new_isin_info.skip_company_validation = true
      new_isin_info.isin = company_symbol
      new_isin_info.save!
      company_info = new_isin_info
    end
    company_info
  end

  def self.options_for_isin_select
    IsinInfo.all.order(:isin).pluck(:isin)
  end

end
