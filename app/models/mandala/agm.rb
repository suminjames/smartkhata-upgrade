# == Schema Information
#
# Table name: agm
#
#  id              :integer          not null, primary key
#  company_code    :string
#  agm_date        :string
#  book_close_date :string
#  agm_place       :string
#  divident_pct    :string
#  bonus_pct       :string
#  right_share     :string
#  fiscal_year     :string
#

class Mandala::Agm < ApplicationRecord
  self.table_name = "agm"
end
