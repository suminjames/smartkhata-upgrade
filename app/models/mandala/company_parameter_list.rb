# == Schema Information
#
# Table name: company_parameter_list
#
#  id               :integer          not null, primary key
#  company_code     :string
#  share_code       :string
#  no_of_shares     :string
#  share_no_from    :string
#  share_no_to      :string
#  par_value_share  :string
#  paid_value_share :string
#

class Mandala::CompanyParameterList < ApplicationRecord
  self.table_name = "company_parameter_list"
end
