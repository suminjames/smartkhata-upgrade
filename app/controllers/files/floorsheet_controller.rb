class Files::FloorsheetController < ApplicationController
	@@file = FileUpload::FILES[:floorsheet];

	def new
	end

	def import

		# get file from import
		@file = params[:file];


		if @file == nil
			flash.now[:error] = "Please Upload a valid file"
			@error = true
		else
			# read the xls file
			xlsx = Roo::Spreadsheet.open(@file)

			# hash to store unique combination of isin, trasaction type (buy/sell), client
			hash_dp = Hash.new

			# array to store processed data
			@processed_data = []

			# get bill number
			@bill_number = get_bill_number


			# grab date from the first record
			if xlsx.sheet(0).row(13)[0].nil?
				flash.now[:error] = "The file is empty"
				@error = true
				return
			end
			date_data = xlsx.sheet(0).row(13)[0].to_s
			@date = "#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}"

			# do not reprocess file if it is already uploaded
			floorsheet_file = FileUpload.find_by(file: @@file, report_date: @date.to_date)
			unless floorsheet_file.nil?
				flash.now[:error] = "The file is already uploaded"
				@error = true
				return
			end

			fy_code = get_fy_code
			# loop through 13th row to last row
			# data starts from 13th row
			ActiveRecord::Base.transaction do
				(13..(xlsx.sheet(0).last_row)).each do |i|
				# (13..15).each do |i|
					@row_data = xlsx.sheet(0).row(i)
					break if @row_data[0] == nil
					@processed_data  << process_records(@row_data,hash_dp, fy_code)
				end
			end
		end
	end

	def get_commission_rate(amount)
		case amount
			when 0..25000
				"flat_25"
			when 25001..50000
				"0.1"
			when 50001..500000
				"0.9"
			when 500001..100000
				"0.8"
			else
				"0.7"
		end
	end

	def get_commision(amount)
		commision_rate = get_commission_rate(amount)
		if (commision_rate == "flat_25")
			return 25
		else
			return amount * commision_rate.to_i * 0.01
		end
	end

	# arr  => [Contract No.,Symbol,Buyer Broking Firm Code,Seller Broking Firm Code,Client Name,Client Code,Quantity ,Rate,Amount,Stock Comm.,Bank Deposit,NIL]
	# hash_dp => custom hash to store unique isin , buy/sell, customer per day
	def process_records(arr,hash_dp, fy_code)
		@dp = 0
		bill = nil

		@type_of_transaction = ShareTransaction.trans_types['buy']
		client = ClientAccount.find_or_create_by!(name: arr[4].upcase, nepse_code: arr[5].upcase)


		# check for the bank deposit value which is available only for buy
		if arr[10].nil?
			# if client is charged already with dp fee  for selling particular isin in that day, do not charge again
			unless hash_dp.has_key?(arr[5].to_s+arr[1].to_s+'sell')
				@dp = 25
				hash_dp[arr[5].to_s+arr[1].to_s+'sell'] = true
			end
			@type_of_transaction = ShareTransaction.trans_types['sell']
		else
			# create or find a bill by the number
			if hash_dp.has_key?(arr[5].to_s+arr[1].to_s+'buy')
				bill = Bill.find_or_create_by!(bill_number: hash_dp[arr[5].to_s+arr[1].to_s+'buy'], fy_code: fy_code)
			else
				@dp = 25
				hash_dp[arr[5].to_s+arr[1].to_s+'buy'] = @bill_number
				bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code, client_account_id: client.id) do |b|
					b.bill_type = Bill.types['receive']
					b.client_name = arr[4]
				end
				@bill_number += 1
			end

		end

		# @amnt: amount of the transaction
		# @commission: Broker commission
		# @nepse: nepse commission
		# @tds: tds amount deducted from the broker commission
		# @sebon: sebon fee
		# @bank_deposit: deposit to nepse
		@cgt = 0
		@amnt = arr[8]
		@commision = get_commision(@amnt)
		@purchase_commission = @commision * 0.75
		@nepse = @commision * 0.25
		@tds = @commision * 0.75 * 0.15
		@sebon = @amnt * 0.00015
		@bank_deposit = @nepse + @tds + @sebon + @amnt

		# amount to be debited to client account
		@client_dr = @nepse + @sebon + @amnt + @purchase_commission + @dp

		# get company information to store in the share transaction
		company_info = IsinInfo.find_or_create_by(isin: arr[1])

		trasaction = ShareTransaction.create(
			contract_no: arr[0].to_i,
			isin_info_id: company_info.id,
			buyer: arr[2],
			seller: arr[3],
			quantity: arr[6],
			rate: arr[7],
			share_amount: arr[8],
			sebo: @sebon,
			commission: @commision,
			dp_fee: @dp,
			cgt: @cgt,
			net_amount: @client_dr,
			bank_deposit: arr[10],
			transaction_type: @type_of_transaction,
			date: @date
		)

		if @type_of_transaction == ShareTransaction.trans_types['buy']
			bill.share_transactions << trasaction
			bill.net_amount += trasaction.net_amount
			bill.save!
		end



		# create client ledger if not exist
		client_ledger = Ledger.find_or_create_by!(client_code: arr[5]) do |ledger|
			ledger.name = arr[4]
		end
		# assign the client ledgers to group clients
		client_group = Group.find_or_create_by!(name: "Clients")
		client_group.ledgers << client_ledger

		# find or create predefined ledgers
		purchase_commission = Ledger.find_or_create_by!(name: "Purchase Commission")
		nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
		tds_ledger = Ledger.find_or_create_by!(name: "TDS")
		dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")

		# update ledgers value
		voucher = Voucher.create!
		process_accounts(client_ledger,voucher,true,@client_dr)
		process_accounts(nepse_ledger,voucher,false,@bank_deposit)
		process_accounts(tds_ledger,voucher,true,@tds)
		process_accounts(purchase_commission,voucher,false,@purchase_commission)
		process_accounts(dp_ledger,voucher,false,@dp) if @dp > 0

		FileUpload.find_or_create_by!(file: @@file, report_date: @date.to_date)

		arr.push(@client_dr,@tds,@commision,@bank_deposit,@dp)
	end

	def process_accounts(ledger,voucher, debit, amount)

		trn_type = debit ? Particular.trans_types['dr'] : Particular.trans_types['cr']
		closing_blnc = ledger.closing_blnc

		if debit
			ledger.closing_blnc += amount
		else
			ledger.closing_blnc -= amount
		end

		Particular.create!(trn_type: trn_type, ledger_id: ledger.id, name: "as being purchased", voucher_id: voucher.id, amnt: amount, opening_blnc: closing_blnc ,running_blnc: ledger.closing_blnc )
		ledger.save!
	end

	# get a unique bill number based on fiscal year
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

	def get_fy_code
		@cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]
		(date_bs + (date_bs.to_i+1).to_s).to_i
	end


end