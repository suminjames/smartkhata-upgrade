module CustomDateModule
  # Converts a BS date  to AD date
  # params bs_date	- BS date is a String, strictly in YYYY-MM-DD format, not `Date` object.
  # return - AD date is a `Date` object
  def bs_to_ad (bs_date)
    year, month, day = bs_date.to_s.split('-').map(&:to_i)
    @cal = NepaliCalendarPlus::CalendarPlus.new
    return @cal.bs_to_ad(year, month, day)
  end

  # This method's existence serves the purpose of supporting legacy code, which has a lot of dependency to this method.
  # Originally(in the past), the method returned BS date, a `Date` object
  # Currently, the method returns BS date, a String, strictly in YYYY-MM-DD format, not `Date` object.
  def ad_to_bs(ad_date)
    ad_to_bs_string(ad_date)
  end

  # Converts an AD date to BS date string
  # params ad_date - AD date  is a `Date` object not `String`
  # return - BS date is a String, strictly in YYYY-MM-DD format, not `Date` object.
  def ad_to_bs_string (ad_date)
    ad_date = Date.parse(ad_date.to_s)
    @cal = NepaliCalendarPlus::CalendarPlus.new
    return @cal.ad_to_bs_string(ad_date.year, ad_date.month, ad_date.day)
  end

  # workaround for some modules that extend
  def ad_to_bs_string_public(ad_date)
    ad_to_bs_string(ad_date)
  end

  # Converts an AD date to BS date string
  # params ad_date - AD date  is a `Date` object not `String`
  # return - BS date is a hash, with signature {:year=> 2072, :month => 2, :day => 32}, not `Date` object.
  def ad_to_bs_hash(ad_date)
    ad_date = Date.parse(ad_date.to_s)
    @cal = NepaliCalendarPlus::CalendarPlus.new
    return @cal.ad_to_bs_hash(ad_date.year, ad_date.month, ad_date.day)
  end

  #
  # Checks to see if the passed in ad_date is convertible to bs_date.
  # NepaliCalendarPlus only converts ad_date > '1944/01/01'
  #
  def is_convertible_ad_date? (ad_date)
    @cal = NepaliCalendarPlus::CalendarPlus.new
    ref_day_eng = Date.parse(@cal.ref_date['ad_to_bs']['ad'])
    return @cal.ad_date_in_range?(ad_date, ref_day_eng)
  end

  # Checks whether or not a date_bs is valid
  def is_valid_bs_date? (bs_date)
    begin
      bs_to_ad(bs_date)
    rescue RuntimeError
      # handle invalid date
      return false
    end
    return true
  end

  # Checks if a date is parsable. This is different from checking if the date is valid.
  # For instance: 2012-02-31 is a parsable date format but not a valid date.
  # params date - is primarily a string (but can also a date object)
  # returns - the validity of the date as per Ruby's (smart) date parsing.
  # OPTIMIZE find a better way to do this
  def parsable_date? (date)
    # if date is any object but String, the following `to_s` conversion is needed.
    date = date.to_s
    begin
      Date.parse(date)
    rescue ArgumentError
      # handle invalid date
      return false
    end
    return true
  end


  def test
    puts "hello"
  end
  module_function :ad_to_bs, :ad_to_bs_string
end
