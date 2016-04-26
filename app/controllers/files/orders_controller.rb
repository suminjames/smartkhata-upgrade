class Files::OrdersController < ApplicationController
	# 	@@file = FileUpload::FILES[:order];

	@@file = FileUpload::FILES[:floorsheet];
	@@file_name_contains = "ORDER"

	def new
	end

	def import
    # get file from import
    @file = params[:file];

    # read the xls file
    xlsx = Roo::Spreadsheet.open(@file)

    # array to store processed data
    @processed_data = []
    @raw_data = []

    # loop through 13th row to last row
    # parse the data
    @total_amount = 0
    count = 0
    # header = xlsx.sheet(0).row(11)
    # (14..(xlsx.sheet(0).last_row)).each do |i|
    #   row = Hash[[header, xlsx.sheet(0).row(i)].transpose]
    #   count += 1
    #   @row_data = row.to_hash
    #   puts @row_data
    #   break if count > 5
    # end

    xlsx.sheet(0).each(
        id: 'Order ID',
        symbol: 'Symbol',
        client_name: 'Client Name',
        client_code: 'Client Code',
        price: 'Price',
        quantity: 'Quantity',
        amount: 'Amount',
        pending_qty: 'Pending Quantity',
        order_time: 'Order Time',
        order_type: 'Order Type',
        order_segment: 'Order Segment',
        order_condition: 'Order Condition',
        # order_condition: 'Order Condition',
        order_state: 'Order State'
    ) do |hash|
      count += 1
      puts hash.inspect
      break if count > 5
      # => { id: 1, name: 'John Smith' }
    end

  end
end
