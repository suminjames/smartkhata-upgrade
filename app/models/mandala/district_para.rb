# == Schema Information
#
# Table name: district_para
#
#  id            :integer          not null, primary key
#  zone_code     :string
#  district_code :string
#  district_name :string
#

class Mandala::DistrictPara < ApplicationRecord
  self.table_name = "district_para"
end
