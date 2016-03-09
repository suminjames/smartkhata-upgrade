module ApplicationHelper
	def link_to_add_fields(name, f, association)
		new_object = 	f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render(association.to_s.singularize + "_fields" , f: builder)
		end
		link_to(name, '#', class: "add_fields",  data:  {id: id, fields: fields.gsub("\n", "")})
	end

	# Get fy code based on current year
	# TODO modify the method to return based on fiscal years
	def get_fy_code
		@cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]
		(date_bs + (date_bs.to_i+1).to_s).to_i
	end


	# Get a unique bill number based on fiscal year
	# The returned bill number is an increment (by 1) of the previously stored bill_number.
	def get_bill_number
		bill = Bill.where(fy_code: get_fy_code).last
		# initialize the bill with 1 if no bill is present
		if bill.nil?
			1
		else
			# increment the bill number
			bill.bill_number + 1
		end
	end

	# process accounts to make changes on ledgers
	def process_accounts(ledger,voucher, debit, amount)

		transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
		closing_blnc = ledger.closing_blnc
		puts transaction_type
		if debit
			ledger.closing_blnc += amount
		else
			ledger.closing_blnc -= amount
		end

		Particular.create!(transaction_type: transaction_type, ledger_id: ledger.id, name: "as being purchased", voucher_id: voucher.id, amnt: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc )
		ledger.save!
	end


	# method to calculate the broker commission
	def get_broker_commission(commission)
		commission * 0.75
	end

	# method to calculate the tds
	def get_broker_tds(broker_commission)
		broker_commission * 0.15
	end
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
	# return - AD date is a `Date` object
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

end
