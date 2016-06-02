# == Schema Information
#
# Table name: calendars
#
#  id             :integer          not null, primary key
#  bs_date        :text             not null
#  ad_date        :date             not null
#  is_holiday     :boolean          default("false")
#  is_trading_day :boolean          default("true")
#  holiday_type   :integer          default("0")
#  remarks        :text
#  creator_id     :integer
#  updater_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Calendar < ActiveRecord::Base
  include ::Models::Updater
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  enum holiday_type: [:not_applicable, :saturday, :public_holiday, :unforeseen_holiday]

  # Populates dates without any prejudices but two -
  # 1. saturday is a holiday.
  # 2. friday is a non-trading day
  def self.populate_calendar
    @cal = NepaliCalendarPlus::CalendarPlus.new

    from_date_ad = @cal.bs_to_ad(2073, 1, 1)
    to_date_ad = @cal.bs_to_ad(2074, 12, 30)
    # to_date_ad = @cal.bs_to_ad(2083, 12, 30)

    from_date_ad.upto(to_date_ad) do |ad_date|
      bs_date = @cal.ad_to_bs_hash(ad_date.year, ad_date.month, ad_date.day)
      date_hash = { }
      unless bs_date_already_in_db? (bs_date)
        date_hash[:bs_date] = self.stringify_date_hash(bs_date)
        date_hash[:ad_date] = ad_date
        if ad_date.saturday?
          date_hash[:is_holiday] = true
          date_hash[:holiday_type] = Calendar.holiday_types[:saturday]
          date_hash[:is_trading_day] = false
          date_hash[:remarks] = 'Saturday'
        end
        if ad_date.friday?
          date_hash[:is_trading_day] = false
          date_hash[:remarks] = 'Friday'
        end
        Calendar.create(date_hash)
      end
    end
  end

  # Checks the passed date against the 'Calendars' table in the database
  # @param bs_date - signature of bs_date {:year=> year, :month => month, :day => day}
  def self.bs_date_already_in_db? (bs_date)
    bs_date_str = self.stringify_date_hash(bs_date)
    Calendar.exists? bs_date: bs_date_str
  end

  # @param bs_date - signature of bs_date {:year=> year, :month => month, :day => day}
  def self.stringify_date_hash(bs_date)
    bs_date[:year].to_s + '-' + bs_date[:month].to_s + '-' + bs_date[:day].to_s
  end

  # Get T+x trading days.
  # @params from_ad_date - Date object, not bs_date hash
  # returns ad_date
  # Note: A trading day doesn't include holidays and fridays
  def self.t_plus_x_trading_days(from_ad_date, number_of_days)
    calendar_date_obj = Calendar.where('ad_date >?', from_ad_date).where(is_trading_day: true).limit(number_of_days).last
    calendar_date_obj.ad_date
  end

  # Get T+3 trading date
  def self.t_plus_3_trading_days(from_ad_date)
    self.t_plus_x_trading_days(from_ad_date, 3)
  end

end
