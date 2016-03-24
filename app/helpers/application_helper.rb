module ApplicationHelper
	# moved the fiscal year module so that it is accesible in modal too
	include FiscalYearModule

	def link_to_add_fields(name, f, association, extra_info = nil	)
		new_object = 	f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			# render(association.to_s.singularize + "_fields" , f: builder)
			render :partial => association.to_s.singularize + "_fields", :locals => { :f => builder, :extra_info => extra_info }
		end
		link_to(name, '#', class: "add_fields btn btn-primary",  data:  {id: id, fields: fields.gsub("\n", "")})
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
	def process_accounts(ledger,voucher, debit, amount, descr)

		transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
		closing_blnc = ledger.closing_blnc
		puts transaction_type
		if debit
			ledger.closing_blnc += amount
		else
			ledger.closing_blnc -= amount
		end

		Particular.create!(transaction_type: transaction_type, ledger_id: ledger.id, name: descr, voucher_id: voucher.id, amnt: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc)
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


	# Converts a number to its words equivalent Nepali/Indian style (with Lakhs instead of Millions).
	def arabic_word(decimal)
		word = decimal.to_f.to_words
		if word.kind_of?(Array)
			word = "#{word[0]} And #{word[1]} Paisa"
		end
		word.titleize
	end

	# Similar to number_to_currency but with arabic way of comma separation.
	def arabic_number(decimal)
		decimal.to_f.round(2).to_amount
	end

end
