require 'test_helper'

class NepaliCalendarPlusTest < ActiveSupport::TestCase

  include CustomDateModule

  def test_bs_to_ad_conversion
    date_ad = '2016-10-20'
    date_ad = Date.parse(date_ad)
    date_bs = '2073-07-04'
    assert_equal date_ad, bs_to_ad(date_bs)
  end

  # Should throw a runtime error
  def test_bs_to_ad_conversion_out_of_lower_boundary
    date_ad = '2016-10-20'
    date_ad = Date.parse(date_ad)
    date_bs = '1999-01-01'
    assert_equal date_ad, bs_to_ad(date_bs)
    # assert_raises(RuntimeError) { bs_to_ad(date_bs) }
  end

  # Should throw a runtime error
  def test_bs_to_ad_conversion_out_of_upper_boundary
    date_ad = '2016-10-20'
    date_ad = Date.parse(date_ad)
    date_bs = '2091-01-01'
    assert_equal date_ad, bs_to_ad(date_bs)
    # assert_raises(RuntimeError) { bs_to_ad(date_bs) }
  end

  def test_ad_to_bs_feb_29
    date_ad = "2016-02-29"
    date_ad = Date.parse(date_ad)
    date_bs = "2072-11-17"
    assert_equal date_ad, bs_to_ad(date_bs)
  end

  def test_is_valid_bs_date_method_with_valid_bs_date
    date_bs = "2073-02-32"
    assert_equal true, is_valid_bs_date?(date_bs)
  end

  def test_is_valid_bs_date_method_with_invalid_bs_date
    date_bs = "2073-01-32"
    assert_equal false, is_valid_bs_date?(date_bs)
  end

end
