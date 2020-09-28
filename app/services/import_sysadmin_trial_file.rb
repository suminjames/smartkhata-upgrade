class ImportSysadminTrialFile < ImportFile
  include ApplicationHelper

  # process the file
  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|
          # initial load
          next if hash[:ac_code].nil?

          client_account = ClientAccount.find_by(ac_code: hash[:ac_code])
          next if client_account.nil?

          ledger = client_account.ledger || Ledger.new
          ledger.name = hash[:ac_name]
          ledger.opening_balance = (hash[:balance_dr]).positive? ? hash[:balance_dr] : hash[:balance_cr] * -1
          ledger.closing_balance = ledger.opening_balance
          ledger.client_account_id = client_account.id
          ledger.save!
        end
      end
    end
    @processed_data
  end

  def extract_xlsx(file)
    xlsx = Roo::Spreadsheet.open(file)
    #
    # begin
    data_sheet = xlsx.sheet(0)
    (8..(data_sheet.last_row)).each do |i|
      hash = {}
      row_data = data_sheet.row(i)
      hash[:ac_code] = row_data[0]
      hash[:ac_name] = row_data[1]
      hash[:balance_dr] = row_data[6].to_s.delete(',').to_f
      hash[:balance_cr] = row_data[7].to_s.delete(',').to_f
      @processed_data << hash
    end
    # rescue
    # 	@error_message = "something went wrong" and return
    # end
  end
end
