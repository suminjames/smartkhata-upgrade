#TODO: Bill status should be (be default) in pending
class Files::FloorsheetsController < Files::FilesController
	@@file = FileUpload::FILES[:floorsheet];
	@@file_name_contains = "FLOORSHEET"

	def new
	end

	def import

		# get file from import
		@file = params[:file];


		# grab date from the first record
		file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

		# read the xls file
		xlsx = Roo::Spreadsheet.open(@file)

		# hash to store unique combination of isin, transaction type (buy/sell), client
		hash_dp = Hash.new

		# array to store processed data
		@processed_data = []
    @raw_data = []

		# get bill number
		@bill_number = get_bill_number



		# grab date from the first record
		file_error("Please verify and Upload a valid file") and return if (is_invalid_file_data(xlsx))

		date_data = xlsx.sheet(0).row(12)[3].to_s



		# convert a string to date
		@date = convert_to_date("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")


		# TODO remove this
		@older_detected= false
		if @date.nil?
			@older_detected = true
			date_data = xlsx.sheet(0).row(12)[0].to_s
			@date = convert_to_date("#{date_data[0..3]}-#{date_data[4..5]}-#{date_data[6..7]}")
		end

		file_error("Please upload a valid file. Are you uploading the processed floorsheet file?") and return if @date.nil?

		# do not reprocess file if it is already uploaded
		floorsheet_file = FileUpload.find_by(file: @@file, report_date: @date)
		# raise soft error and return if the file is already uploaded
		file_error("The file is already uploaded") and return unless floorsheet_file.nil?


		fy_code = get_fy_code
		# loop through 13th row to last row
		# parse the data
		@total_amount = 0
		(12..(xlsx.sheet(0).last_row)).each do |i|

			@row_data = xlsx.sheet(0).row(i)

			if (@row_data[0].to_s.tr(' ','') == 'Total')
				@total_amount = @row_data[21].to_f
				break
			end

			break if @row_data[0] == nil
			# rawdata =[
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
			# ]
			# TODO remove this hack
			if @older_detected
				@raw_data << [@row_data[0],@row_data[1],@row_data[2],@row_data[3],@row_data[4],@row_data[5],@row_data[6],@row_data[7],@row_data[8],@row_data[9],@row_data[10]]
				@total_amount_file = 0
			else
				@raw_data << [@row_data[3],@row_data[7],@row_data[8],@row_data[10],@row_data[12],@row_data[15],@row_data[17],@row_data[19],@row_data[20],@row_data[23],@row_data[26]]
				# sum of the amount section should be equal to the calculated sum
				@total_amount_file = @raw_data.map {|d| d[8].to_f}.reduce(0, :+)
			end
		end



		file_error("The amount dont match up") and return  if (@total_amount_file - @total_amount).abs > 0.1

		ActiveRecord::Base.transaction do
      @raw_data.each do |arr|
        @processed_data  << process_records(arr, hash_dp, fy_code)
      end
      FileUpload.find_or_create_by!(file: @@file, report_date: @date)
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
	# ]
	# hash_dp => custom hash to store unique isin , buy/sell, customer per day
	def process_records(arr ,hash_dp, fy_code)
		contract_no = arr[0].to_i
		company_symbol = arr[1]
		buyer_broking_firm_code = arr[2]
		seller_broking_firm_code = arr[3]
		client_name = arr[4]
		client_nepse_code = arr[5]
		share_quantity =  arr[6].to_i
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
					b.bill_type = Bill.bill_types['purchase']
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
		purchase_commission = commission * (0.75)
		nepse = commission * 0.25
		tds = purchase_commission * 0.15
		sebon = amnt * 0.00015
		bank_deposit = nepse + tds + sebon + amnt

		# amount to be debited to client account
		# @client_dr = nepse + sebon + amnt + purchase_commission + dp
		@client_dr = (bank_deposit + purchase_commission - tds + dp) if bank_deposit.present?

		# get company information to store in the share transaction
		company_info = IsinInfo.find_or_create_by(isin: company_symbol)

		# TODO: Include base price

		transaction = ShareTransaction.create(
			contract_no: contract_no,
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

		share_inventory = ShareInventory.find_or_create_by(
			client_account_id: client.id,
			isin_info_id: company_info.id
			)
		share_inventory.lock!

		if transaction.buy?
			share_inventory.total_in += transaction.quantity
			share_inventory.floorsheet_blnc += transaction.quantity
		else
			share_inventory.total_out += transaction.quantity
			share_inventory.floorsheet_blnc -= transaction.quantity
		end
		
		share_inventory.save!

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

			description = "as being purchased (#{share_quantity}*#{company_symbol}@#{share_rate})"
			# update ledgers value
			voucher = Voucher.create!(date_bs: ad_to_bs(Time.now))
			voucher.bills << bill
			voucher.share_transactions << transaction
			voucher.desc = "as being purchased (#{share_quantity}*#{company_symbol}@#{share_rate})"
			voucher.complete!
			voucher.save!
			#
			# transaction.voucher =  voucher
			# transaction.save!

			#TODO replace bill from particulars with bill from voucher
			process_accounts(client_ledger,voucher,true,@client_dr,description)
			process_accounts(nepse_ledger,voucher,false,bank_deposit,description)
			process_accounts(tds_ledger,voucher,true,tds,description)
			process_accounts(purchase_commission_ledger,voucher,false,purchase_commission,description)
			process_accounts(dp_ledger,voucher,false,dp,description) if dp > 0

		end


		arr.push(@client_dr,tds,commission,bank_deposit,dp)
	end

	# return true if the floor sheet data is invalid
	def is_invalid_file_data(xlsx)
		xlsx.sheet(0).row(11)[1].to_s.tr(' ','') != 'Contract No.' && xlsx.sheet(0).row(12)[0].nil?
	end
end
