# == Schema Information
#
# Table name: tax_para
#
#  id                  :integer          not null, primary key
#  unit_id             :string
#  effective_date_from :string
#  effective_date_to   :string
#  rate                :string
#  tax_name            :string
#

class Mandala::TaxPara < ActiveRecord::Base
  self.table_name = "tax_para"
end
