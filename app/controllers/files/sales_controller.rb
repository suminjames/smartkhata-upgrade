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

          transaction = ShareTransaction.find_by(
            contract_no: hash[:contract_no].to_i,
            transaction_type: ShareTransaction.transaction_types[:sell]
      		)


          if transaction.nil?
            @success_check = false
            raise ActiveRecord::Rollback
            return
          end

          transaction.settlement_id = hash[:settlement_id]
          transaction.cgt = hash[:cgt]
          transaction.base_price = hash[:base]
          # net amount is the amount that is payble to the client after charges
          transaction.net_amount = hash[:amount_receivable].to_f- (transaction.commission_amount*0.75) - transaction.dp_fee
          transaction.amount_receivable = hash[:amount_receivable].to_f
          transaction.save!
          
          @sales_settlement_id = SalesSettlement.find_or_create_by!(settlement_id: settlement_id).id
        end
      end

      puts @success_check
      unless @success_check
        flash.now[:error] = "Please upload corresponding Floorsheet First"
        @error = true
        return
      end

		end
	end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
end
