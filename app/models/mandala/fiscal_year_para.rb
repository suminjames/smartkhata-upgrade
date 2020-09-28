# == Schema Information
#
# Table name: fiscal_year_para
#
#  id               :integer          not null, primary key
#  fiscal_year      :string
#  fy_start_date    :string
#  fy_end_date      :string
#  entered_by       :string
#  entered_date     :string
#  year_end         :string
#  status           :string
#  fy_start_date_bs :string
#  fy_end_date_bs   :string
#

class Mandala::FiscalYearPara < ActiveRecord::Base
  self.table_name = "fiscal_year_para"
end
