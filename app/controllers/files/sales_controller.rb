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
      return
		else
			begin
			  xlsx = Roo::Spreadsheet.open(@file, extension: :xlsx)
			rescue Zip::Error
			  xlsx = Roo::Spreadsheet.open(@file)
			end


      # initial constants
      tds_rate = 0.15
      broker_commission_rate = 0.75
      # nepse charges tds which is payable by the broker
      # so we need to deduct  the tds while charging the client
      chargeable_on_sale_rate = broker_commission_rate * (1 - tds_rate)



      # grab settlement id from the fifth row first column
      settlement_id = xlsx.sheet(0).row(5)[0].to_i

			# do not reprocess file if it is already uploaded
			settlement_cm_file = SalesSettlement.find_by(settlement_id: settlement_id)
			unless settlement_cm_file.nil?
				flash.now[:error] = "The file is already uploaded"
				@error = true
				return
			end



			# @x = Date.parse(xlsx.sheet(0).row(5)[9].tr('()',""))
			@processed_data= []

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

      # by default the process is incomplete
      @success_check = true

      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|

          if (hash[:contract_no].present?)
            transaction = ShareTransaction.find_by(
              contract_no: hash[:contract_no].to_i,
              transaction_type: ShareTransaction.transaction_types[:sell]
        		)


            if transaction.nil?
              @success_check = false
              raise ActiveRecord::Rollback
              return
            end

            amount_receivable = hash[:amount_receivable].delete(',').to_f
            transaction.settlement_id = hash[:settlement_id]
            transaction.cgt = hash[:cgt].delete(',').to_f

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

            @sales_settlement_id = SalesSettlement.find_or_create_by!(settlement_id: settlement_id).id
          end
        end
      end

      unless @success_check
        flash.now[:error] = "Please upload corresponding Floorsheet First"
        @error = true
        return
      end
      redirect_to sales_settlement_path(@sales_settlement_id)

		end
	end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
