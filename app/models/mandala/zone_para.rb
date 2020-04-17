# == Schema Information
#
# Table name: zone_para
#
#  id            :integer          not null, primary key
#  regional_code :string
#  zone_code     :string
#  zone_name     :string
#

class Mandala::ZonePara < ApplicationRecord
  self.table_name = "zone_para"
end
