class Mandala::CompanyParameter < ActiveRecord::Base
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