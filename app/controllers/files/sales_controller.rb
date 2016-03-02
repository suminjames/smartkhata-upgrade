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

			# @x = Date.parse(xlsx.sheet(0).row(5)[9].tr('()',""))
			@processed_data= []
			(5..(xlsx.sheet(0).last_row)).each do |i|

				break if xlsx.sheet(0).row(i)[0] == nil
        # @processed_data  << xlsx.sheet(0).row(i)
			end


      xlsx.sheet(0).each(
        settlement_id: 'Settlement ID',
        trade_start_date: 'Trade Start Date',
        sell_cm_id: 'SELL CM ID',
        script_number: 'Script Number',
        script_name: 'Script Name',
        quantity: 'Quantity',
        vag: 'Client Code',
        buy_cm_id: 'Buy CM ID',
        contract_no: 'Contract No',
        rate: 'Rate',
        contract_amount: 'Contract Amount (CA)',
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

      @processed_data.each do |hash|

        transaction = ShareTransaction.find_or_create_by(
          contract_no: hash[:contract_no].to_i,
    		)
        transaction.settlement_id = hash[:settlement_id]

      end

      # @process = @processed_data[0][:settlement_id]
      # @x = get_fy_code
		end
	end
end
