module CustomDateModule
	# Converts a BS date (strictly in YYYY-MM-DD format) to AD date (of the same format)
	# params bs_date	- BS date  is a `Date` object not `String`
	# return - AD date is a `Date` object
	# TODO: Add validation for 1) the incoming BS date format, 2) the correctness(actual availability) of the BS date
	def bs_to_ad (bs_date)
		@cal = NepaliCalendar::Calendar.new
		bs_date = Date.parse(bs_date.to_s)
		return @cal.bs_to_ad(bs_date.year, bs_date.month, bs_date.day)
	end

	# Converts a AD date (strictly in YYYY-MM-DD format) to BS date (of the same format)
	# params ad_date- AD date  is a `Date` object not `String`
	# return - BS date is a `Date` object
	# TODO: Add validation for 1) the incoming AD date format, 2) the correctness(actual availability) of the AD date
	def ad_to_bs (ad_date)
		@cal = NepaliCalendar::Calendar.new
		ad_date = Date.parse(ad_date.to_s)
		return @cal.ad_to_bs(ad_date.year, ad_date.month, ad_date.day)
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

	def bs_to_ad_from_string(bs_date)
		@cal = NepaliCalendar::Calendar.new
		bs_string_arr =  bs_date.to_s.split(/-/)
		new_date = cal.bs_to_ad(bs_string_arr[0],bs_string_arr[1], bs_string_arr[2])
	end

end
