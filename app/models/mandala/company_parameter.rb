# == Schema Information
#
# Table name: company_parameter
#
#  id              :integer          not null, primary key
#  company_code    :string
#  nepse_code      :string
#  company_name    :string
#  sector_code     :string
#  listing_date    :string
#  incorpyear      :string
#  company_address :string
#  listing_bs_date :string
#  no_of_share     :string(8)
#  demat           :string
#  isin_info_id    :integer
#

class Mandala::CompanyParameter < ApplicationRecord
  self.table_name = "company_parameter"

  def create_isin_info
    isin_info = ::IsinInfo.where(isin: nepse_code).first
    return isin_info if isin_info.present?

    isin_info = ::IsinInfo.create!({
                                     isin: nepse_code,
                                     company: company_name
                                   })
  end

  def get_isin_info_id
    return isin_info_id if isin_info_id.present?

    isin_info = create_isin_info
    self.isin_info_id = isin_info.id
    self.save!
    self.isin_info_id
  end
end
