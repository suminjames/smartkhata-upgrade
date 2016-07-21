require 'test_helper'
include FiscalYearModule

class FiscalYearModuleTest < ActiveSupport::TestCase
  def setup
    @date = "2016-7-15".to_date
    @fy_code = 7273
  end

  def get_correct_fy_code
    assert get_fy_code(@date).equal? @fy_code
  end

  def test_get_fiscal_year_last_day
    assert_equal fiscal_year_last_day(@fy_code), @date
  end

  def test_date_valid_for_fy_code
    assert date_valid_for_fy_code(@date, @fy_code)
    assert_not date_valid_for_fy_code(@date, 7374)
  end
end