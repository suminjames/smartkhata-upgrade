# == Schema Information
#
# Table name: capital_gain_detail
#
#  id               :integer          not null, primary key
#  group_code       :string
#  capital_gain_pct :string
#  effective_from   :string
#  effective_to     :string
#

class Mandala::CapitalGainDetail < ActiveRecord::Base
  self.table_name = "capital_gain_detail"
end
