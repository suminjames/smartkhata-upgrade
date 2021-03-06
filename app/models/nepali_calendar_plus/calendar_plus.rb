require 'date'
class NepaliCalendarPlus::CalendarPlus
  BS = {
    2000 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2001 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2002 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2003 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2004 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2005 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2006 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2007 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2008 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2009 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2010 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2011 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2012 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2013 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2014 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2015 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2016 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2017 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2018 => [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2019 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2020 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2021 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2022 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2023 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2024 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2025 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2026 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2027 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2028 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2029 => [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2030 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2031 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2032 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2033 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2034 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2035 => [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2036 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2037 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2038 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2039 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2040 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2041 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2042 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2043 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2044 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2045 => [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2046 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2047 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2048 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2049 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2050 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2051 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2052 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2053 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2054 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2055 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2056 => [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2057 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2058 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2059 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2060 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2061 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2062 => [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
    2063 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2064 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2065 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2066 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2067 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2068 => [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2069 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2070 => [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2071 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2072 => [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2073 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2074 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2075 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2076 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2077 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2078 => [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2079 => [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2080 => [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2081 => [31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
    2082 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
    2083 => [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
    2084 => [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
    2085 => [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30],
    2086 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
    2087 => [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
    2088 => [30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30],
    2089 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
    2090 => [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30]
  }.freeze

  MONTHS = %w[Baisakh Jestha Ashad Shrawn Bhadra Ashwin Kartik Mangshir Poush Magh Falgun Chaitra].freeze
  DAYS = %w[Aitabar Sombar Mangalbar Budhbar Bihibar Sukrabar Sanibar].freeze

  def initialize(y = Date.today.year, m = Date.today.month, d = Date.today.day)
    @year = y
    @month = m
    @day = d
  end

  class << self
    def today
      today = Date.today
      self.new.ad_to_bs_hash(today.year, today.month, today.day)
    end
  end

  def ad_to_bs_hash(year, month, day)
    raise 'Invalid date!' unless valid_ad_date?(year, month, day)

    ref_day_eng = Date.parse(ref_date['ad_to_bs']['ad'])
    date_ad = Date.parse("#{year}/#{month}/#{day}")
    return unless ad_date_in_range?(date_ad, ref_day_eng)

    days = total_days(date_ad, ref_day_eng)
    get_bs_date(days, ref_date['ad_to_bs']['bs'])
  end

  def ad_to_bs_string(year, month, day)
    bs_date_hash = ad_to_bs_hash(year, month, day)
    return bs_date_hash[:year].to_s.rjust(4, '0') + '-' + bs_date_hash[:month].to_s.rjust(2, '0') + '-' + bs_date_hash[:day].to_s.rjust(2, '0') if bs_date_hash
  end

  # returns a bs_date hash with signature {:year=> 2072, :month => 2, :day => 32}
  def get_bs_date(days, ref_day_nep)
    year, month, day = ref_day_nep.split('/').map(&:to_i)
    i = year
    j = month
    while days != 0
      break unless BS[i]

      bs_month_days = BS[i][j - 1]
      day += 1

      if day > bs_month_days
        month += 1
        day = 1
        j += 1
      end

      if month > 12
        year += 1
        month = 1
      end

      if j > 12
        j = 1
        i += 1
      end

      days -= 1
    end

    { year: year, month: month, day: day }
  end

  def bs_to_ad(year, month, day)
    ref_day_nep = ref_date['bs_to_ad']['bs']

    date_bs = { year: year.to_i, month: month.to_i, day: day.to_i }
    return unless bs_date_in_range?(date_bs, Date.parse(ref_day_nep))

    raise 'Invalid date!' unless valid_bs_date?(year, month, day)

    get_ad_date(year, month, day, ref_day_nep)
  end

  def get_ad_date(year, month, day, ref_day_nep)
    ref_year, ref_month, ref_day = ref_day_nep.split('/').map(&:to_i)
    k = ref_year

    # No. of Days from year
    i = 0
    days = 0
    j = 0
    while i < (year.to_i - ref_year)
      i += 1
      while j < 12
        days += BS[k][j]
        j += 1
      end
      j = 0
      k += 1
    end

    # No. of Days from month
    j = 0
    while j < (month.to_i - ref_month)
      days += BS[k][j]
      j += 1
    end

    days += (day.to_i - ref_day)
    Date.parse(ref_date['bs_to_ad']['ad']) + days
  end

  def total_days(date_eng, reference_date)
    days = date_eng - reference_date
    days.to_i
  end

  def ad_date_in_range?(date, reference_date)
    date > reference_date
  end

  # @param date - a hash with signature {:year=> 2072, :month => 2, :day => 32}
  # @param reference_date - Date object
  def bs_date_in_range?(date, reference_date)
    return_value = false
    if date[:year] > reference_date.year
      return_value = true
    elsif date[:year] == reference_date.year
      if date[:month] > reference_date.month
        return_value = true
      elsif date[:month] == reference_date.month
        return_value = true if date[:day] >= reference_date.day
      end
    end
    return_value
  end

  def valid_bs_date?(year, month, day)
    BS.key?(year) && (1..12).cover?(month.to_i) && (1..BS[year.to_i][month - 1]).cover?(day.to_i)
  end

  def valid_ad_date?(year, month, day)
    Date.valid_date?(year.to_i, month.to_i, day.to_i)
  end

  def ref_date
    {
      'bs_to_ad' => { 'bs' => '2000/01/01', 'ad' => '1943/04/14' },
      'ad_to_bs' => { 'bs' => '2000/09/17', 'ad' => '1944/01/01' }
    }
  end
end
