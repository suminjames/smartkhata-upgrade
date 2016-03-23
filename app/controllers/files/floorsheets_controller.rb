#TODO: Bill status should be (be default) in pending
class Files::FloorsheetsController < ApplicationController
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

			# hash to store unique combination of isin, transaction type (buy/sell), client
			hash_dp = Hash.new

			# array to store processed data
			@processed_data = []

			# get bill number
			@bill_number = get_bill_number


			# grab date from the first record
			if xlsx.sheet(0).row(12)[0].nil?
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
				(12..(xlsx.sheet(0).last_row)).each do |i|
				# (13..15).each do |i|
					@row_data = xlsx.sheet(0).row(i)
					break if @row_data[0] == nil
					@processed_data  << process_records(@row_data, hash_dp, fy_code)
				end
			end
		end
	end

	def get_commission_rate(amount)
		case amount
			when 0..2500
				"flat_25"
			when 2501..50000
				"1"
			when 50001..500000
				"0.9"
			when 500001..1000000
				"0.8"
			else
				"0.7"
		end
	end

	def get_commission(amount)
		commission_rate = get_commission_rate(amount)
		if (commission_rate == "flat_25")
			return 25
		else
			return amount * commission_rate.to_f * 0.01
		end
	end

	# TODO: Change arr to hash (maybe)
	# arr =[
	# 	Contract No.,
	# 	Symbol,
	# 	Buyer Broking Firm Code,
	# 	Seller Broking Firm Code,
	# 	Client Name,
	# 	Client Code,
	# 	Quantity,
	# 	Rate,
	# 	Amount,
	# 	Stock Comm.,
	# 	Bank Deposit,
	# 	NIL
	# ]
	# hash_dp => custom hash to store unique isin , buy/sell, customer per day
	def process_records(arr ,hash_dp, fy_code)
		contract_no = arr[0]
		company_symbol = arr[1]
		buyer_broking_firm_code = arr[2]
		seller_broking_firm_code = arr[3]
		client_name = arr[4]
		client_nepse_code = arr[5]
		share_quantity =  arr[6]
		share_rate = arr[7]
		share_net_amount = arr[8]
		#TODO look into the usage of arr[9] (Stock Commission)
		# commission = arr[9]
		bank_deposit = arr[10]
		# arr[11] = NIL


		dp = 0
		bill = nil

		type_of_transaction = ShareTransaction.transaction_types['buy']
		client = ClientAccount.find_or_create_by!(name: client_name.titleize, nepse_code: client_nepse_code.upcase)


		# check for the bank deposit value which is available only for buy
		if bank_deposit.nil?
			# if client is charged already with dp fee  for selling particular isin in that day, do not charge again
			unless hash_dp.has_key?(client_name.to_s+company_symbol.to_s+'sell')
				dp = 25
				hash_dp[client_name.to_s+company_symbol.to_s+'sell'] = true
			end
			type_of_transaction = ShareTransaction.transaction_types['sell']
		else
			# create or find a bill by the number
			if hash_dp.has_key?(client_name.to_s+company_symbol.to_s+'buy')
				bill = Bill.find_or_create_by!(bill_number: hash_dp[client_name.to_s+company_symbol.to_s+'buy'], fy_code: fy_code)
			else
				dp = 25
				hash_dp[client_name.to_s+company_symbol.to_s+'buy'] = @bill_number
				bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code, client_account_id: client.id) do |b|
					b.bill_type = Bill.bill_types['receive']
					b.client_name = client_name
				end
				@bill_number += 1
			end

		end

		# amnt: amount of the transaction
		# commission: Broker commission
		# nepse: nepse commission
		# tds: tds amount deducted from the broker commission
		# sebon: sebon fee
		# bank_deposit: deposit to nepse
		cgt = 0
		amnt = share_net_amount
		commission = get_commission(amnt)
		commission_rate = get_commission_rate(amnt)
		purchase_commission = commission * 0.75
		nepse = commission * 0.25
		tds = commission * 0.75 * 0.15
		sebon = amnt * 0.00015
		bank_deposit = nepse + tds + sebon + amnt

		# amount to be debited to client account
		# @client_dr = nepse + sebon + amnt + purchase_commission + dp
		@client_dr = bank_deposit + purchase_commission - tds + dp if bank_deposit.present?

		# get company information to store in the share transaction
		company_info = IsinInfo.find_or_create_by(isin: company_symbol)

		# TODO: Include base price

		transaction = ShareTransaction.create(
			contract_no: contract_no.to_i,
			isin_info_id: company_info.id,
			buyer: buyer_broking_firm_code,
			seller: seller_broking_firm_code,
			quantity: share_quantity,
			share_rate: share_rate,
			share_amount: share_net_amount,
			sebo: sebon,
			commission_rate: commission_rate,
			commission_amount: commission,
			dp_fee: dp,
			cgt: cgt,
			net_amount: @client_dr,#calculated as @client_dr = nepse + sebon + amnt + purchase_commission + dp. Not to be confused with share_amount
			bank_deposit: bank_deposit,
			transaction_type: type_of_transaction,
			date: @date,
			client_account_id: client.id
		)

		if type_of_transaction == ShareTransaction.transaction_types['buy']
			bill.share_transactions << transaction
			bill.net_amount += transaction.net_amount
			bill.balance_to_pay = bill.net_amount
			bill.save!


			# create client ledger if not exist
			client_ledger = Ledger.find_or_create_by!(client_code: client_nepse_code) do |ledger|
				ledger.name = client_name
				ledger.client_account_id = client.id
			end
			# assign the client ledgers to group clients
			client_group = Group.find_or_create_by!(name: "Clients")
			client_group.ledgers << client_ledger

			# find or create predefined ledgers
			purchase_commission_ledger = Ledger.find_or_create_by!(name: "Purchase Commission")
			nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
			tds_ledger = Ledger.find_or_create_by!(name: "TDS")
			dp_ledger = Ledger.find_or_create_by!(name: "DP Fee/ Transfer")

			description = "as being purchased(#{share_quantity}*#{company_symbol}@#{share_rate})"
			# update ledgers value
			voucher = Voucher.create!
			voucher.bills << [bill]
			voucher.save!
			#TODO replace bill from particulars with bill from voucher
			process_accounts(client_ledger,voucher,true,@client_dr,description,voucher.id)
			process_accounts(nepse_ledger,voucher,false,bank_deposit,description,voucher.id)
			process_accounts(tds_ledger,voucher,true,tds,description,voucher.id)
			process_accounts(purchase_commission_ledger,voucher,false,purchase_commission,description,voucher.id)
			process_accounts(dp_ledger,voucher,false,dp,description,voucher.id) if dp > 0

		end





		FileUpload.find_or_create_by!(file: @@file, report_date: @date.to_date)

		arr.push(@client_dr,tds,commission,bank_deposit,dp)
	end


end
