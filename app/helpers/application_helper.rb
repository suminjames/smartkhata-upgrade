module ApplicationHelper
	# moved the fiscal year module so that it is accesible in modal too
	include FiscalYearModule
	include CustomDateModule
	
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
		ledger.lock!
		transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
		closing_blnc = ledger.closing_blnc
		if debit
			ledger.closing_blnc += amount
		else
			ledger.closing_blnc -= amount
		end

		Particular.create!(transaction_type: transaction_type, ledger_id: ledger.id, name: descr, voucher_id: voucher.id, amnt: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc)
		ledger.save!
	end

	def reverse_accounts(particular,voucher, descr)
		transaction_type = particular.cr? ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
		ledger = particular.ledger
		amount = particular.amnt
		ledger.lock!
		closing_blnc = ledger.closing_blnc
		if particular.cr?
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

	# Gets the list of latest price crawled from  http://www.nepalstock.com.np/main/todays_price.
	# In the returned hash, 'isin' is the key and 'price' is the value.
	def get_latest_isin_price_list
		companies = IsinInfo.all

		price_hash = {}
		companies.each do |isin|
			price_hash[isin.isin] = isin.last_price.to_f
		end

		price_hash
	end
end
