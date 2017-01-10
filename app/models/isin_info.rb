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

  validates_presence_of :company
  validates :isin, uniqueness: true, presence: true, :case_sensitive => false


  scope :by_isin_info_id, ->(isin_info_id) { where(id: isin_info_id) }
  scope :by_sector, ->(sector_string) { where("sector": sector_string) }

  filterrific(
      default_filter_params: { },
      available_filters: [
          :by_isin_info_id,
          :by_sector
      ]
  )

  # Used by combobox in view
  # In rare circumstances, the data crawled from nepse's site has (apparently errorenous) numeric(eg: 001) value as isin code for a company. This method makes it easier to identify a company in these cases.
  def name_and_code
    "#{self.isin} (#{self.company})"
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

  def self.find_similar_to_term(search_term)
    search_term = search_term.present? ? search_term.to_s : ''
    isin_infos = IsinInfo.where("company ILIKE :search OR isin ILIKE :search", search: "%#{search_term}%").order(:isin).pluck_to_hash(:id, :company, :isin)
    isin_infos.collect do |isin_info|
      identifier = "#{isin_info['isin']}"
      if isin_info['company'].present?
        identifier += " (#{isin_info['company']})"
      end
      { :text=> identifier, :id => isin_info['id'].to_s }
    end
  end

end
