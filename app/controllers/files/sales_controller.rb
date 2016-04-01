class Files::SalesController < Files::FilesController
  @@file_name_contains = "CM05"
  def new
    # new
  end

	def import
		# authorize self
		@file = params[:file];
    # grab date from the first record
    file_error("Please Upload a valid file") and return if (is_invalid_file(@file, @@file_name_contains))

		begin
		#   xlsx = Roo::Spreadsheet.open(@file, extension: :xlsx)
		# rescue Zip::Error
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
		file_error("The file is already uploaded") and return unless settlement_cm_file.nil?



		# @x = Date.parse(xlsx.sheet(0).row(5)[9].tr('()',""))
		@processed_data= []

    begin
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
    rescue
      file_error("Please Upload a valid file. Header dont match") and return
    end
    @processed_data = @processed_data.drop(1) if @processed_data[0][:settlement_id]=='Settlement ID'

    ActiveRecord::Base.transaction do
      @processed_data.each do |hash|
        # corrupt file check
        unless hash[:contract_no].present?
          file_error("The file you have uploaded does not seem correct")
          raise ActiveRecord::Rollback
          break
        end



        transaction = ShareTransaction.find_by(
          contract_no: hash[:contract_no].to_i,
          transaction_type: ShareTransaction.transaction_types[:sell]
    		)


        if transaction.nil?
          file_error("Please upload corresponding Floorsheet First")
          raise ActiveRecord::Rollback
          break
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
      end
      @sales_settlement_id = SalesSettlement.find_or_create_by!(settlement_id: settlement_id).id
    end

    # if error return to the page
    return if @error

    # else redirect to settlement path
    redirect_to sales_settlement_path(@sales_settlement_id)
	end

  # method to calculate the base price
  def get_base_price
    share_amount
  end
  # return true if the floor sheet data is invalid
	# def is_invalid_file_data(xlsx)
	# 	xlsx.sheet(0).row(11)[1].to_s.tr(' ','') != 'Contract No.' && xlsx.sheet(0).row(12)[0].nil?
	# end
end
