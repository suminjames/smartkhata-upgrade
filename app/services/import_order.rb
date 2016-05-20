class ImportOrder < ImportFile
  include ApplicationHelper
  $isin_infos = []

# process the file
  def process
    open_file(@file)
    @date_set= Set.new
    unless @error_message
      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|

          # to incorporate the symbol to string
          hash = hash.deep_stringify_keys!

          @date_set.add(Date.parse(hash['ORDER_DATE_TIME'].to_s))

          # Each order_id listed in the excel sheet should be checked for duplicate entry in the database.
          if is_record_available_in_db(hash['ORDER_ID'])
            import_error("File upload cancelled! An order with order id " + hash['ORDER_ID'].to_s + " seems to have been previously uploaded! Please double check and upload.")
            raise ActiveRecord::Rollback
            break
          end

          # Get isin reference
          # TODO(sarojk): Check if isin is valid and throw error accordingly
          isin_info_id = get_isin_id(hash['SYMBOL'])

          # Get client reference
          # -If client doesn't exist, create one.
          client_account_obj = ClientAccount.create_with(name: hash['CLIENT_NAME']).find_or_create_by(nepse_code: hash['CLIENT_CODE'])
          client_account_id = client_account_obj.id

          # Get order reference
          date = Date.parse(hash['ORDER_DATE_TIME'].to_s)
          order_obj = Order.where(client_account_id: client_account_id, date: date).first
          # -If order for a given day doesn't exist, create one.
          if order_obj.blank?
            order_obj = Order.new()
            order_obj.order_number = get_new_order_number
            order_obj.client_account_id = client_account_id
            order_obj.fy_code= get_fy_code
            order_obj.date = Date.parse(hash['ORDER_DATE_TIME'].to_s)
            order_obj.save!
          end
          order_id = order_obj.id

          # Create OrderDetails obj
          #   t.string   "order_id"
          #   t.decimal  "price"
          #   t.integer  "isin_info_id"
          #   t.integer  "quantity"
          #   t.decimal  "amount"
          #   t.integer  "pending_quantity"
          #   t.integer  "typee"
          #   t.integer  "segment"
          #   t.integer  "condition"
          #   t.integer  "state"
          #   t.datetime "date_time"
          order_detail_obj = OrderDetail.new()
          order_detail_obj.order_id = order_id
          order_detail_obj.order_nepse_id = hash['ORDER_ID']
          order_detail_obj.price = hash['PRICE']
          order_detail_obj.isin_info_id= isin_info_id
          order_detail_obj.quantity = hash['QUANTITY']
          order_detail_obj.amount = hash['AMOUNT']
          order_detail_obj.pending_quantity = hash['PENDING_QUANTITY']
          order_detail_obj.date_time = Time.parse(hash['ORDER_DATE_TIME'].to_s)
          order_detail_obj.typee = hash['ORDER_TYPE'].downcase
          order_detail_obj.segment = hash['ORDER_SEGMENT'].downcase
          # Use of Nonee because 'none' is reserved word. See OrderDetail model's 'enum condition' for more.
          order_detail_obj.condition = (hash['ORDER_CONDITION'] == 'None') ? 'nonee' : hash['ORDER_CONDITION'].downcase
          order_detail_obj.state = hash['ORDER_STATE'].downcase
          order_detail_obj.save!
        end

        # After all rows have beeen succesfully saved, log their dates in FileUpload table.
        @date_set.each do |date|
          FileUpload.find_or_create_by!(file_type: FileUpload::file_types[:orders], report_date: date)
        end
      end
    end
    @processed_data
  end

  def get_isin_id(symbol)
    isin_obj = IsinInfo.find_by(isin: symbol)
    if isin_obj.nil?
      return -1
    else
      return isin_obj.id
    end
  end

# Looks at only the first order listed in the excel sheet, checks its availability in the db, and decide if the file has already been uploaded before.
# This is not perfect implementation to avoid record duplication.
# Instead, each order_id listed in the excel sheet should be checked for duplicate entry in the database.
  def is_previously_uploaded_file(order_id)
    record = Order.find_by(order_id: order_id)
    !record.nil?
  end

# This is an almost perfect implementation to avoid record duplication.
  def is_record_available_in_db(order_id)
    record = OrderDetail.find_by(order_nepse_id: order_id)
    !record.nil?
  end

# Method overwrite ImportFile's Method
  def extract_csv(file)
    raise NotImplementedError
  end

# Signature of a row
# [
# 0 => 1.0,  (S.N)
# 1 => nil,
# 2 => 201601016317326.0, (Order Id)
# 3 => nil,
# 4 => nil,
# 5 => nil,
# 6 => "RHPC", (Symbol)
# 7 => nil,
# 8 => "ANIL SHRESTHA", (Client Name)
# 9 => nil,
# 10 => "ANS17", (Client Code)
# 11 => nil,
# 12 => 368.0, (Price)
# 13 => nil,
# 14 => 1.0, (Quantity)
# 15 => nil,
# 16 => 368.0, (Amount)
# 17 => nil,
# 18 => nil,
# 19 => nil,
# 20 => 0.0,  (Pending Quantity)
# 21 => Fri, 01 Jan 2016, (Order Date Time)
# 22 => "Buy", (Order Type)
# 23 => "CT", (Order Segment)
# 24 => "None", (Order Condition)
# 25 => nil,
# 26 => "Executed" (Order State)
# ]

  def non_nil_row_indices
    [0, 2, 6, 8, 10, 12, 14, 16, 20, 21, 22, 23, 24, 26]
  end

  def get_hash_keys
    [:ORDER_ID,
     :SYMBOL,
     :CLIENT_NAME,
     :CLIENT_CODE,
     :PRICE,
     :QUANTITY,
     :AMOUNT,
     :PENDING_QUANTITY,
     :ORDER_DATE_TIME,
     :ORDER_TYPE,
     :ORDER_SEGMENT,
     :ORDER_CONDITION,
     :ORDER_STATE]
  end

  def is_valid_row?(row=[])
    expected_row_length = 27
    return false if row.length != expected_row_length
    non_nil_row_indices.each do |index|
      return false if row[index].nil?
    end
    return true
  end

# Signature of a stripped row
# [
# 0 => 1.0,  (S.N)
# 1 => nil,
# 2 => 201601016317326.0, (Order Id)
# 3 => nil,
# 4 => nil,
# 5 => nil,
# 6 => "RHPC", (Symbol)
# 7 => nil,
# 8 => "ANIL SHRESTHA", (Client Name)
# 9 => nil,
# 10 => "ANS17", (Client Code)
# 11 => nil,
# 12 => 368.0, (Price)
# 13 => nil,
# 14 => 1.0, (Quantity)
# 15 => nil,
# 16 => 368.0, (Amount)
# 17 => nil,
# 18 => nil,
# 19 => nil,
# 20 => 0.0,  (Pending Quantity)
# 21 => Fri, 01 Jan 2016, (Order Time)
# 22 => "Buy", (Order Type)
# 23 => "CT", (Order Segment)
# 24 => "None", (Order Condition)
# 25 => nil,
# 26 => "Executed" (Order State)
# ]
  def strip_row_of_nil_entries(row)
    stripped_valid_row = []
    non_nil_row_indices.each do |index|
      stripped_valid_row << row[index]
    end
    stripped_valid_row
  end

  def get_hash_equivalent_of_row(row)
    keys = get_hash_keys
    # The 0-th indexed value in a valid row is Serial Number of the row. This is to be excluded fom the row hash. Therefore, the row shift.
    row.shift
    hashed_row = {}
    (0..12).each do |i|
      if i == 0
        #order_id(at index 0) is taken as 201601016317314.0 . Strip the decimal. 
        hashed_row[keys[i]] = row[i].to_s.split(".")[0]
      else
        hashed_row[keys[i]] = row[i]
      end
    end
    hashed_row
  end

# Grand Total row Signature
# [
# 0 => "Grand Total",
# 1 => nil,
# 2 => nil,
# 3 => nil,
# 4 => nil,
# 5 => nil,
# 6 => nil,
# 7 => nil,
# 8 => nil,
# 9  => nil,
# 10 => nil,
# 11 => nil,
# 12 => nil,
# 13 => nil,
# 14 => 5740200.0,  (total_quantity)
# 15 => nil,
# 16 => 3055787848.22, (total_amount)
# 17 => nil,
# 18 => nil,
# 19 => nil,
# 20 => 2518498.0, (total_pending_quantity)
# 21 => nil,
# 22 => nil,
# 23 => nil,
# 24 => nil,
# 25 => nil,
# 26 => nil
# ]
# Note: The literal last row has Nepal Stock Exchange Company contact information. However, the last non-trivial(or relevant) row is few rows above the literal last row, and it has 'Grand Total' cell in it.
# If 'Grand Total' row not found, return -1
  def grand_total_row_index(excel_sheet)
    row_stop = excel_sheet.last_row
    if row_stop > ORDER_BEGIN_ROW
      row_stop.downto(ORDER_BEGIN_ROW).each do |i|
        return i if excel_sheet.row(i).include? 'Grand Total'
      end
    end
    return -1
  end

# runtime_total = Hash.new(0)
#initialize runtime_totals as a global variable
# $runtime_totals = {:total_quantity => 0, :total_amount => 0, :total_pending_quantity => 0 }
  $runtime_totals = Hash.new(0)

# Runtime_total's signature similar to Grand Total row hash Signature
# {:total_quanity => 'QUANTITY_HERE', :total_amount => 'AMOUNT_HERE', :total_pending_quantity => 'PENDING AMOUNT HERE'}
  def update_runtime_totals(hashed_row)
    $runtime_totals[:total_quantity] +=hashed_row[:QUANTITY]
    $runtime_totals[:total_amount] += hashed_row[:AMOUNT]
    $runtime_totals[:total_pending_quantity] += hashed_row[:PENDING_QUANTITY]
  end

# Grand Total row hash Signature
# {:total_quanity => 'QUANTITY_HERE', :total_amount => 'AMOUNT_HERE', :total_pending_quantity => 'PENDING AMOUNT HERE'}
  def grand_total_row_hash(excel_sheet)
    grand_total_row = excel_sheet.row(grand_total_row_index(excel_sheet))
    grand_total = {}
    grand_total[:total_quantity] = grand_total_row[14]
    grand_total[:total_amount] = grand_total_row[16]
    grand_total[:total_pending_quantity] = grand_total_row[20]
    grand_total
  end

# Bottom-most order row (before Grand Total)
# Note: There is an empty row in between the bottom-most order row & grand_total_row
# If row not found, return -1
  def bottom_most_order_row_index(excel_sheet)
    grand_total_row = grand_total_row_index(excel_sheet)
    if grand_total_row > ORDER_BEGIN_ROW
      grand_total_row.downto(ORDER_BEGIN_ROW).each do |i|
        return i if is_valid_row?(excel_sheet.row(i))
      end
    end
    return -1
  end

  ORDER_BEGIN_ROW = 14

  def extract_xls(file)
    @rows = []
    @processed_data = []
    # begin
    xlsx = Roo::Spreadsheet.open(file)
    excel_sheet = xlsx.sheet(0)
    order_end_row = bottom_most_order_row_index(excel_sheet)
    (ORDER_BEGIN_ROW..order_end_row).each do |i|
      row = excel_sheet.row(i)
      if is_valid_row?(row)
        stripped_row = strip_row_of_nil_entries(row)
        hashed_row = get_hash_equivalent_of_row(stripped_row)
        update_runtime_totals(hashed_row)
        # Looks at only the first order listed in the excel sheet, checks its availability in the db, and decide if the file has already been uploaded before.
        #if i == ORDER_BEGIN_ROW
        #if is_previously_uploaded_file(hashed_row[:ORDER_ID])
        #@error_message = "Looks like you are trying to upload an already uploaded file! Please upload a valid file." and return
        #end
        #end
        @processed_data << hashed_row
      else
        @error_message = "Row #{i.to_s} is invalid! Please upload a valid file." and return
      end
    end

    # Parsing the rows complete
    # Return error if totals of rows doesn't equal those in grand total row 
    if grand_total_row_hash(excel_sheet) != $runtime_totals
      @error_message = "The sum of totals of rows doesn't add up to those in grand total row! Please upload a valid file." and return
    end

    # TODO(sarojk): Resolve Rescue
    # rescue
    #   @error_message = "Processing error! Please upload a valid file." and return
    # end

  end

end