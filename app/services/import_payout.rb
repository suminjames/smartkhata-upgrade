class ImportPayout < ImportFile
	# process the file
	def process
		# initial constants
		tds_rate = 0.15
		broker_commission_rate = 0.75
		# nepse charges tds which is payable by the broker
		# so we need to deduct  the tds while charging the client
		chargeable_on_sale_rate = broker_commission_rate * (1 - tds_rate)

		open_file(@file)

		# inorder to icorporate both row to hash in csv and the hash from roo xls
		# used the "SETT_ID" instead of [:SETT_ID]
    # TODO fix this statement
		@settlement_id = @processed_data[0]['SETT_ID'] ?  @processed_data[0]['SETT_ID'].to_i :  @processed_data[0][:SETT_ID].to_i
		# do not reprocess file if it is already uploaded
		settlement_cm_file = SalesSettlement.find_by(settlement_id: @settlement_id)
		@error_message = "The file is already uploaded" unless settlement_cm_file.nil?

		unless @error_message
			ActiveRecord::Base.transaction do
				@processed_data.each do |hash|
					# to incorporate the symbol to string
					hash = hash.deep_stringify_keys!
					# also we can hash.deep_symbolize_keys!


					unless hash['SETT_ID'].to_i == @settlement_id
						import_error("The file you have uploaded has multiple settlement ids")
						raise ActiveRecord::Rollback
						break
					end

					# corrupt file check
					unless hash['CONTRACTNO'].present?
						puts hash
						import_error("The file you have uploaded has missing contract number")
						raise ActiveRecord::Rollback
						break
					end



					transaction = ShareTransaction.includes(:client_account).find_by(
						contract_no: hash['CONTRACTNO'].to_i,
						transaction_type: ShareTransaction.transaction_types[:sell]
					)


					if transaction.nil?
						import_error("Please upload corresponding Floorsheet First")
						raise ActiveRecord::Rollback
						break
					end

					amount_receivable = hash['AMOUNTRECEIVABLE'].delete(',').to_f
					transaction.settlement_id = hash['SETT_ID']
					transaction.cgt = hash['CGT'].delete(',').to_f
					transaction.base_price = get_base_price(transaction)
					# TODO remove hard code calculations
					# net amount is the amount that is payble to the client after charges
					# amount receivable from nepse  =  share value - tds ( 15 % of broker commission ) - sebon fee - nepse commission(25% of broker commission )
					# amount payble to client =
					#   + amount from nepse
					#   - broker commission
					#   + tds of broker (it was charged by nepse , so should be reimbursed to client )
					#   - dp fee
					# client pays the commission_amount
					transaction.net_amount = amount_receivable -  ( transaction.commission_amount * chargeable_on_sale_rate ) - transaction.dp_fee
					transaction.amount_receivable = amount_receivable
					transaction.save!
				end
				@sales_settlement_id = SalesSettlement.find_or_create_by!(settlement_id: @settlement_id).id
			end

		end


	end

	def extract_xls(file)
		xlsx = Roo::Spreadsheet.open(file)
		begin
			xlsx.sheet(0).each(
				SETT_ID: 'Settlement ID',
				TRADESTARTDATE: 'Trade Start Date',
				CMID: 'SELL CM ID',
				BUY_CM_ID: 'Buy CM ID',
				SCRIPTSHORTNAME: 'Script Name',
				SCRIPTNUMBER: 'Script Number',
				CONTRACTNO: 'Contract No',
				CLIENTCODE: 'Client Code',
				QUANTITY: 'Quantity',
				RATE: 'Rate',
				CONTRACTAMT: 'Contract Amount (CA)',
				NEPSE_COMMISSION: 'NEPSE COMMISSION',
				SEBON_COMMISSION: 'SEBON COMMISSION',
				TDS: 'TDS',
				CGT: 'CGT',
				CLOSEOUT_AMOUNT: 'CLOSEOUT AMOUNT',
				AMOUNTRECEIVABLE: 'Amount Receivable'
				) do |hash|
				@processed_data  << hash
			end
		rescue
			@error_message = "Please Upload a valid file. Header dont match" and return
		end
		@processed_data = @processed_data.drop(1) if @processed_data[0][:SETT_ID]=='Settlement ID'
	end

	def get_base_price(transaction)
		unless transaction.cgt > 0
			0.0
		else
			if transaction.client_account.individual?
				tax_rate = 0.05
			else
				tax_rate = 0.1
			end
			transaction.share_rate - (transaction.cgt / ( transaction.quantity * tax_rate))
		end
	end
end
