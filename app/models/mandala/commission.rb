# == Schema Information
#
# Table name: commission
#
#  id                  :integer          not null, primary key
#  un_id               :string
#  effective_date_from :string
#  effective_date_to   :string
#

class Mandala::Commission < ActiveRecord::Base
  self.table_name = "commission"
end
