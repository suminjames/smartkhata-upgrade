module ApplicationHelper
	# moved the fiscal year module so that it is accesible in modal too
	include FiscalYearModule
	include CustomDateModule
	include NumberFormatterModule

	def link_to_add_fields(name, f, association, extra_info = nil	)
		new_object = 	f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			# render(association.to_s.singularize + "_fields" , f: builder)
			render :partial => association.to_s.singularize + "_fields", :locals => { :f => builder, :extra_info => extra_info }
		end
		link_to(name, '#', class: "add_fields btn btn-primary",  data:  {id: id, fields: fields.gsub("\n", "")})
	end


	# Get a unique order number based on fiscal year
	# The returned order number is an increment (by 1) of the previously stored order number.
	def get_new_order_number
		order = Order.where(fy_code: get_fy_code).last
		# initialize the orer with 1 if no order is present
		if order.nil?
			1
		else
			# increment the order number
			order.order_number + 1
		end
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
	def process_accounts(ledger,voucher, debit, amount, descr, transaction_date = Time.now)
		ledger.lock!
		transaction_type = debit ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
		closing_blnc = ledger.closing_blnc
		dr_amount = 0
		cr_amount = 0
    daily_report = LedgerDaily.find_or_create_by!(ledger_id: ledger.id, date: transaction_date.to_date )

		if debit
			ledger.closing_blnc += amount
      ledger.dr_amount += amount
			dr_amount = amount
      daily_report.closing_blnc += amount
		else
			ledger.closing_blnc -= amount
      ledger.cr_amount += amount
      daily_report.closing_blnc -= amount
			cr_amount = amount
		end


    daily_report.opening_blnc ||= ledger.opening_blnc
    daily_report.dr_amount += dr_amount
    daily_report.cr_amount += cr_amount
    daily_report.save!

		Particular.create!(transaction_type: transaction_type, ledger_id: ledger.id, name: descr, voucher_id: voucher.id, amount: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc, transaction_date: transaction_date)
		ledger.save!
	end

	def reverse_accounts(particular,voucher, descr, adjustment = 0.0)
		amount = particular.amount

		# this accounts for the case where whole transaction is cancelled
		# in such case adjustment value is 0
		if ( amount - adjustment).abs > 0.01
			transaction_type = particular.cr? ? Particular.transaction_types['dr'] : Particular.transaction_types['cr']
			ledger = particular.ledger
			amount = particular.amount
			ledger.lock!
			closing_blnc = ledger.closing_blnc

			# in case of client account charge the dp fee.
			if ledger.client_account_id.present?
				amount = amount - adjustment
			end

			if particular.cr?
				ledger.closing_blnc += amount
			else
				ledger.closing_blnc -= amount
			end

			Particular.create!(transaction_type: transaction_type, ledger_id: ledger.id, name: descr, voucher_id: voucher.id, amount: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc)
			ledger.save!
		end

		

	end

	# method to calculate the broker commission
	def get_broker_commission(commission)
		commission * 0.75
	end

	# method to calculate the tds
	def get_broker_tds(broker_commission)
		broker_commission * 0.15
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

# 	get the margin of error amount
	def margin_of_error_amount
		return 0.01
	end
end
