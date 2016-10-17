# == Schema Information
#
# Table name: calendars
#
#  id             :integer          not null, primary key
#  bs_date        :text             not null
#  ad_date        :date             not null
#  is_holiday     :boolean          default(FALSE)
#  is_trading_day :boolean          default(TRUE)
#  holiday_type   :integer          default(0)
#  remarks        :text
#  creator_id     :integer
#  updater_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
