class Files::FloorsheetController < ApplicationController
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

			# loop through 13th row to last row
			# data starts from 13th row
			(13..(xlsx.sheet(0).last_row)).each do |i|	
				@row_data = xlsx.sheet(0).row(i)		
				break if @row_data[0] == nil	
				@processed_data  << process_records(@row_data,hash_dp)
			end
		end
	end

	def get_commision(amount)
		case amount
			when 0..25000
				25
			when 25001..50000
				0.01*amount
			when 50001..500000
				0.009 * amount
			when 500001..100000
				0.008 * amount
			else
				0.007 * amount
		end
	end

	# arr  => [Contract No.,Symbol,Buyer Broking Firm Code,Seller Broking Firm Code,Client Name,Client Code,Quantity ,Rate,Amount,Stock Comm.,Bank Deposit,NIL]
	# hash_dp => custom hash to store unique isin , buy/sell, customer per day
	def process_records(arr,hash_dp)
		@dp = 0
		bill = nil

		@type_of_transaction = ShareTransaction.trans_types['buy']
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
				bill = Bill.find_or_create_by(bill_number: hash_dp[arr[5].to_s+arr[1].to_s+'buy'])
			else
				@dp = 25
				hash_dp[arr[5].to_s+arr[1].to_s+'buy'] = @bill_number
				bill = Bill.find_or_create_by(bill_number: @bill_number)
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
		@nepse = @commision * 0.25
		@tds = @commision * 0.75 * 0.15
		@sebon = @amnt * 0.00015
		@bank_deposit = @nepse + @tds + @sebon + @amnt

		# amount to be debited to client account 
		@client_dr = @nepse + @sebon + @amnt + @commision + @dp
		

		trasaction = ShareTransaction.create(
			contract_no: arr[0].to_s,
			symbol: arr[1], 
			buyer: arr[2],
			seller: arr[3], 
			client_name: arr[4], 
			client_code: arr[5],
			quantity: arr[6],
			rate: arr[7],
			share_amount: arr[8],
			sebo: @sebon,
			commission: @commision,
			dp_fee: @dp,
			cgt: @cgt,
			net_amount: @client_dr,
			bank_deposit: arr[10],
			transaction_type: @type_of_transaction
		)			

		if @type_of_transaction == ShareTransaction.trans_types['buy']
			bill.share_transactions << trasaction
			bill.net_amount += trasaction.net_amount
			bill.save!
		end

		arr.push(@client_dr,@tds,@commision,@bank_deposit,@dp)

		# TODO
		# Create ledgers and vouchers
		# map to user

	end

	# get a unique bill number based on fiscal year
	def get_bill_number
		# convert current date to Bikram Sambat
		@cal = NepaliCalendar::Calendar.new
		date = Date.today
		# grab the last 2 digit of year
		date_bs = @cal.ad_to_bs(date.year, date.month, date.day).year.to_s[2..-1]

		bill = Bill.last

		# initialize the bill with 1 if no bill is present
		if bill.nil?
			(date_bs + (date_bs.to_i+1).to_s + "1").to_i
		else

			# increment the bill number keeping first four digit intact eg 72731
			fy = bill.bill_number.to_s.split(//).first(2).join
			number = bill.bill_number.to_s[4..-1].to_i

			# if the last bill number is from another year than current reinitialize
			if fy == date_bs
				(fy+ ((fy.to_i+1).to_s)+(number+1).to_s).to_i
			else
				(date_bs + (date_bs.to_i+1).to_s + "1").to_i
			end
		end
	end
end