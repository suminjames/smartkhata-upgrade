# == Schema Information
#
# Table name: calendar_parameter
#
#  id          :integer          not null, primary key
#  ad_date     :string
#  bs_date     :string
#  holiday_tag :string
#  day         :string
#

class Mandala::CalendarParameter < ActiveRecord::Base
  self.table_name = "calendar_parameter"
end
