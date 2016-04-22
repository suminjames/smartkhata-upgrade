module FiscalYearModule
  @@fiscal_year_breakpoint = [
    ['7273',Date.parse('2015-7-16'), Date.parse('2016-7-15')],
    ['7374',Date.parse('2016-7-16'), Date.parse('2017-7-15')],
    ['7475',Date.parse('2017-7-16'), Date.parse('2018-7-15')],
    ['7576',Date.parse('2018-7-16'), Date.parse('2019-7-16')],
    ['7677',Date.parse('2019-7-17'), Date.parse('2020-7-15')],
    ['7778',Date.parse('2020-7-16'), Date.parse('2021-7-15')],
    ['7879',Date.parse('2021-7-16'), Date.parse('2022-7-16')],
    ['7980',Date.parse('2022-7-17'), Date.parse('2023-7-16')],
  ]

  def get_fiscal_breakpoint
    return @@fiscal_year_breakpoint
  end
  # Get fy code based on current year
	# TODO modify the method to return based on fiscal years
	def get_fy_code
		# @cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		# date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]
		# (date_bs + (date_bs.to_i+1).to_s).to_i
    fiscal_year_breakpoint = get_fiscal_breakpoint
    fiscal_year_breakpoint.each do |fiscal|
      if date >= fiscal[1] && date <= fiscal[2]
        return fiscal[0]
      end
    end

	end
end
