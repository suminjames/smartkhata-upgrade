class Files::SalesController < ApplicationController
  def new
    # new
  end

	def import
		# authorize self
		@file = params[:file];

		if @file == nil
			flash.now[:error] = "Please Upload a valid file"
			@error = true
		else
			begin
			  xlsx = Roo::Spreadsheet.open(@file, extension: :xlsx)
			rescue Zip::Error
			  xlsx = Roo::Spreadsheet.open(@file)
			end
      # hash to store unique combination of isin, transaction type (buy/sell), client
			hash_dp = Hash.new
			# @x = Date.parse(xlsx.sheet(0).row(5)[9].tr('()',""))
			@processed_data= []
			# (5..(xlsx.sheet(0).last_row)).each do |i|
      #
			# 	break if xlsx.sheet(0).row(i)[0] == nil
      #   # @processed_data  << xlsx.sheet(0).row(i)
			# end



      xlsx.sheet(0).each(
        settlement_id: 'Settlement ID',
        trade_start_date: 'Trade Start Date',
        sell_cm_id: 'SELL CM ID',
        script_number: 'Script Number',
        script_name: 'Script Name',
        quantity: 'Quantity',
        client_code: 'Client Code',
        buy_cm_id: 'Buy CM ID',
        contract_no: 'Contract No',
        share_rate: 'Rate',
        share_amount: 'Contract Amount (CA)',
        nepse_commission: 'NEPSE COMMISSION',
        sebon_commission: 'SEBON COMMISSION',
        tds: 'TDS',
        cgt: 'CGT',
        closeout_amount: 'CLOSEOUT AMOUNT',
        amount_receivable: 'Amount Receivable'
        ) do |hash|
        @processed_data  << hash

      end
      @processed_data = @processed_data.drop(1) if @processed_data[0][:settlement_id]=='Settlement ID'

      # get bill number
			@bill_number = get_bill_number
      fy_code = get_fy_code
      @processed_data.each do |hash|
        client_code = hash[:client_code]
        script_name = hash[:script_name]

        transaction = ShareTransaction.find_or_create_by(
          contract_no: hash[:contract_no].to_i,
          transaction_type: ShareTransaction.transaction_types[:sell]
    		)
        transaction.settlement_id = hash[:settlement_id]
        transaction.cgt = hash[:cgt]
        transaction.base_price = hash[:base]
        # net amount is the amount that is payble to the client after charges
        transaction.net_amount = hash[:amount_receivable].to_f- (transaction.commission_amount*0.75) - transaction.dp_fee
        transaction.amount_receivable = hash[:amount_receivable].to_f
        transaction.save!

        if hash_dp.has_key?(client_code.to_s+script_name.to_s)
          bill = Bill.find_or_create_by!(bill_number: hash_dp[client_code.to_s+script_name.to_s], fy_code: fy_code)
        else
          hash_dp[client_code.to_s+script_name.to_s] = @bill_number
          bill = Bill.find_or_create_by!(bill_number: @bill_number, fy_code: fy_code) do |b|
            b.bill_type = Bill.bill_types['pay']
            
            # TODO possible error location check
            b.client_name = transaction.client_account.name if !transaction.client_account.nil?
          end
          @bill_number += 1
        end

        # TODO possible error location
        bill.client_account_id = transaction.client_account_id
        bill.share_transactions << transaction
  			bill.net_amount += transaction.net_amount
  			bill.save!

      end

      # @process = @processed_data[0][:settlement_id]
      # @x = get_fy_code
		end
	end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
