module FiscalYearModule
  # Get fy code based on current year
	# TODO modify the method to return based on fiscal years
	def get_fy_code
		@cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]
		(date_bs + (date_bs.to_i+1).to_s).to_i
	end
end
