#TODO (subas): Move 'is already uploaded file' logic FROM after open_file completion TO right after the first valid row in excel is parsed.

class ImportPayout < ImportFile
  # process the file
  include ShareInventoryModule
  include CommissionModule
  include CustomDateModule
  include FiscalYearModule

  attr_reader :sales_settlement_ids

  def initialize(file, settlement_date = nil)
    super(file)
    @sales_settlement_ids = []
    @sales_settlement_date_bs = settlement_date
    @sales_settlement_date = nil
  end

  def process(multiple_settlement_ids_allowed = false)
    # initial constants
    tds_rate = 0.15


    open_file(@file)

    # inorder to icorporate both row to hash in csv and the hash from roo xls
    # used the "SETT_ID" instead of [:SETT_ID]
    # TODO fix this statement
    # @settlement_id = @processed_data[0]['SETT_ID'] ? @processed_data[0]['SETT_ID'].to_i : @processed_data[0][:SETT_ID].to_i
    # # do not reprocess file if it is already uploaded
    # settlement_cm_file = SalesSettlement.find_by(settlement_id: @settlement_id)
    # @error_message = "The file is already uploaded" unless settlement_cm_file.nil?

    @error_message ||= "Please Enter a valid date" if @sales_settlement_date_bs.nil? && !multiple_settlement_ids_allowed

    unless @error_message
      # Check the validity for the entered settlement date
      # byepass this if multiple settlement is allowed
      unless multiple_settlement_ids_allowed
        begin
          @sales_settlement_date = bs_to_ad(@sales_settlement_date_bs)
          unless parsable_date?(@sales_settlement_date) && date_valid_for_fy_code(@sales_settlement_date)
            @error_message = "Date is invalid for selected fiscal year"
          end
        rescue
          @error_message = "Date is invalid for selected fiscal year" unless parsable_date?(@sales_settlement_date) && date_valid_for_fy_code(@sales_settlement_date)
        end
        return if @error_message
      end

      # @date = Time.now.to_date
      ActiveRecord::Base.transaction do

        # list of settlement_ids for multiple settlements.
        settlement_ids = Set.new


        @processed_data.each do |hash|
          # to incorporate the symbol to string
          hash = hash.deep_stringify_keys!
          # also we can hash.deep_symbolize_keys!

          settlement_id = hash['SETT_ID'].to_i
          unless settlement_ids.include? settlement_id
            settlement_cm_file = SalesSettlement.find_by(settlement_id: settlement_id)
            unless settlement_cm_file.nil?
              import_error("The file you have uploaded contains  settlement id #{settlement_id} which is already processed")
              raise ActiveRecord::Rollback
              break
            end
          end
          settlement_ids.add(settlement_id)

          unless settlement_ids.size == 1 || multiple_settlement_ids_allowed
            import_error("The file you have uploaded has multiple settlement ids")
            raise ActiveRecord::Rollback
            break
          end

          # corrupt file check
          unless hash['CONTRACTNO'].present?
            import_error("The file you have uploaded has missing contract number")
            raise ActiveRecord::Rollback
            break
          end


          unless hash['TRADE_DATE'].present?
            import_error("Please upload a correct file. Trade date is missing")
            raise ActiveRecord::Rollback
            break
          end

          # @date = Date.parse(hash['TRADE_DATE'])




          transaction = ShareTransaction.includes(:client_account).find_by(
              contract_no: hash['CONTRACTNO'].to_i,
              transaction_type: ShareTransaction.transaction_types[:selling]
          )


          if transaction.nil?
            import_error("Please upload corresponding Floorsheet First. Missing floorsheet data for transaction number #{hash['CONTRACTNO']}")
            raise ActiveRecord::Rollback
            break
          end


          # nepse charges tds which is payable by the broker
          # so we need to deduct  the tds while charging the client
          chargeable_on_sale_rate = broker_commission_rate(transaction.date) * (1 - tds_rate)
          chargeable_by_nepse = nepse_commission_rate(transaction.date) + broker_commission_rate(transaction.date) * tds_rate



          amount_receivable = hash['AMOUNTRECEIVABLE'].delete(',').to_f
          transaction.settlement_id = hash['SETT_ID']
          transaction.closeout_amount = hash['CLOSEOUT_AMOUNT']
          transaction.cgt = hash['CGT'].delete(',').to_f
          transaction.base_price = get_base_price(transaction).to_i
          transaction.remarks = hash['REMARKS']
          transaction.purchase_price = hash['PURCHASE_PRICE']
          transaction.capital_gain = hash['CG']
          transaction.adjusted_sell_price = hash['ADJ_SELL_PRICE']


          # get the shortage quantity
          shortage_quantity = ((transaction.closeout_amount / transaction.share_rate) * 10/12).to_i
          if transaction.closeout_amount.present? && transaction.closeout_amount > 0
            transaction.quantity = transaction.raw_quantity - shortage_quantity
          end
          if shortage_quantity > 0 && transaction.deleted_at.nil?
            update_share_inventory(transaction.client_account_id, transaction.isin_info_id, shortage_quantity, true)
          end

          # net amount is the amount that is payble to the client after charges
          # amount receivable from nepse  =  share value - tds ( 15 % of broker commission ) - sebon fee - nepse commission(25% of broker commission )
          # amount payble to client =
          #   + amount from nepse
          #   - broker commission
          #   + tds of broker (it was charged by nepse , so should be reimbursed to client )
          #   - dp fee
          # client pays the commission_amount

          if transaction.share_amount >= 5000000
            # amount receivable generally includes only cgt
            # calculate the amount_receivable
            amount_receivable = transaction.share_amount - ( transaction.sebo + transaction.commission_amount * chargeable_by_nepse + transaction.cgt )
          end

          # this is the case for close out
          # calculate the charges
          if transaction.closeout_amount > 0
            transaction.net_amount = amount_receivable - (transaction.commission_amount * chargeable_on_sale_rate) - transaction.dp_fee
          else
            transaction.net_amount = amount_receivable - (transaction.commission_amount * chargeable_on_sale_rate) - transaction.dp_fee
          end

          # transaction.net_amount = (transaction.raw_quantity * transaction.share_rate) -  ( transaction.commission_amount * chargeable_on_sale_rate ) - transaction.dp_fee
          transaction.amount_receivable = amount_receivable
          transaction.save!
        end

        # return list of sales settlement ids
        # that track the file uploads for different settlement
        settlement_ids.each do |settlement_id|
          if multiple_settlement_ids_allowed
            @sales_settlement_ids << SalesSettlement.find_or_create_by!(settlement_id: settlement_id).id
          else
            @sales_settlement_ids << SalesSettlement.find_or_create_by!(settlement_id: settlement_id, settlement_date: @sales_settlement_date).id
          end

        end
      end
    end


  end

  def extract_xls(file)
    # xlsx = Roo::Spreadsheet.open(file)
    # begin
    # 	xlsx.sheet(0).each(
    # 		SETT_ID: 'Settlement ID',
    # 		TRADESTARTDATE: 'Trade Start Date',
    # 		CMID: 'SELL CM ID',
    # 		BUY_CM_ID: 'Buy CM ID',
    # 		SCRIPTSHORTNAME: 'Script Name',
    # 		SCRIPTNUMBER: 'Script Number',
    # 		CONTRACTNO: 'Contract No',
    # 		CLIENTCODE: 'Client Code',
    # 		QUANTITY: 'Quantity',
    # 		RATE: 'Rate',
    # 		CONTRACTAMT: 'Contract Amount (CA)',
    # 		NEPSE_COMMISSION: 'NEPSE COMMISSION',
    # 		SEBON_COMMISSION: 'SEBON COMMISSION',
    # 		TDS: 'TDS',
    # 		CGT: 'CGT',
    # 		CLOSEOUT_AMOUNT: 'CLOSEOUT AMOUNT',
    # 		AMOUNTRECEIVABLE: 'Amount Receivable'
    # 		) do |hash|
    # 		@processed_data  << hash
    # 	end
    # rescue
    # 	@error_message = "Please Upload a valid file. Header dont match" and return
    # end
    # @processed_data = @processed_data.drop(1) if @processed_data[0][:SETT_ID]=='Settlement ID'
    @error_message = "Please Upload a CSV file." and return
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
      transaction.share_rate - (transaction.cgt / (transaction.quantity * tax_rate))
    end
  end
end
