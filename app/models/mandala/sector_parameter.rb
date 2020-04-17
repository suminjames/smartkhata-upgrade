# == Schema Information
#
# Table name: sector_parameter
#
#  id          :integer          not null, primary key
#  sector_code :string
#  sector_name :string
#

class Mandala::SectorParameter < ApplicationRecord
  self.table_name = "sector_parameter"
end
