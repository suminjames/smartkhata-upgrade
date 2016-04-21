# == Schema Information
#
# Table name: calendars
#
#  id         :integer          not null, primary key
#  year       :integer          not null
#  month      :integer          not null
#  day        :integer          not null
#  is_holiday :boolean          default("false")
#  date_type  :integer          not null
#  remarks    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Calendar < ActiveRecord::Base
end
