class FilesImportServices::ImportCm31 < ImportFile
  # process the file
  include ApplicationHelper
  include ShareInventoryModule

  attr_reader :nepse_settlement_ids, :selected_branch_id

  def initialize(file, current_tenant, selected_fy_code, settlement_date = nil, current_user)
    super(file)
    @current_user = current_user
    @nepse_settlement_ids = []
    @nepse_settlement_date_bs = settlement_date
    @nepse_settlement_date = nil
    @current_tenant = current_tenant
    @selected_fy_code = selected_fy_code
  end

  def process
    # initial constants
    tds_rate = 0.15
    open_file(@file)

    @error_message ||= "Please Enter a valid date" if @nepse_settlement_date_bs.nil?

    unless @error_message

      begin
        @nepse_settlement_date = bs_to_ad(@nepse_settlement_date_bs)
        @error_message = "Date is invalid for selected fiscal year" unless parsable_date?(@nepse_settlement_date) && date_valid_for_fy_code(@nepse_settlement_date, @selected_fy_code)
      rescue
        @error_message = "Date is invalid for selected fiscal year" unless parsable_date?(@nepse_settlement_date) && date_valid_for_fy_code(@nepse_settlement_date, @selected_fy_code)
      end
      return if @error_message

      # @date = Time.now.to_date
      ActiveRecord::Base.transaction do
        # list of settlement_ids for multiple settlements.
        settlement_ids = Set.new
        @processed_data.each do |hash|
          # to incorporate the symbol to string
          hash = hash.deep_stringify_keys!
          # also we can hash.deep_symbolize_keys!

          settlement_id = hash['SETTLEMENTID'].to_i
          unless settlement_ids.include? settlement_id
            settlement_cm_file = NepsePurchaseSettlement.find_by(settlement_id: settlement_id)
            unless settlement_cm_file.nil?
              import_error("The file you have uploaded contains  settlement id #{settlement_id} which is already processed")
              raise ActiveRecord::Rollback
              break
            end
          end
          settlement_ids.add(settlement_id)

          # corrupt file check
          if hash['CONTRACTNUMBER'].blank?
            import_error("The file you have uploaded has missing contract number")
            raise ActiveRecord::Rollback
            break
          end

          transaction = ShareTransaction.includes(:client_account).find_by(
            contract_no: hash['CONTRACTNUMBER'].to_i,
            transaction_type: ShareTransaction.transaction_types[:buying]
          )

          if transaction.nil?
            import_error("Please upload corresponding Floorsheet First. Missing floorsheet data for transaction number #{hash['CONTRACTNUMBER']}")
            raise ActiveRecord::Rollback
            break
          end

          shortage_quantity = hash['SHORTAGEQTY'].to_i
          trade_quantity = hash['TRADEDQTY'].to_i

          if trade_quantity != transaction.quantity
            import_error("Traded quantity dont match for transaction number #{hash['CONTRACTNUMBER']}")
            raise ActiveRecord::Rollback
            break
          end

          close_out_amount = hash['CLOSEOUTCRAMT'].delete(',').to_f
          transaction.settlement_id = hash['SETTLEMENTID']
          transaction.closeout_amount = close_out_amount
          company_symbol = transaction.isin_info.isin
          share_rate = transaction.share_rate
          client_account = transaction.client_account
          client_ledger = client_account.ledger
          client_name = client_account.name
          cost_center_id = client_account.branch_id
          settlement_date = @settlement_date

          transaction.quantity = transaction.raw_quantity - shortage_quantity if transaction.closeout_amount.present? && transaction.closeout_amount > 0
          update_share_inventory(transaction.client_account_id, transaction.isin_info_id, shortage_quantity, @current_user.id, false) if shortage_quantity > 0 && transaction.deleted_at.nil?

          description = "Shortage Share Adjustment(#{shortage_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{transaction.contract_no}) of #{client_name} purchased on #{ad_to_bs(transaction.date)}"
          voucher = Voucher.create!(date: @nepse_settlement_date, branch_id: cost_center_id, current_user_id: @current_user.id)
          voucher.desc = description

          nepse_ledger = Ledger.find_or_create_by!(name: "Nepse Purchase")
          closeout_ledger = Ledger.find_or_create_by!(name: "Close Out")

          # closeout debit to nepse
          process_accounts(nepse_ledger, voucher, true, close_out_amount, description, cost_center_id, settlement_date, @current_user)
          process_accounts(closeout_ledger, voucher, false, close_out_amount, description, cost_center_id, settlement_date, @current_user)
          voucher.complete!
          voucher.save!

          # if @current_tenant.closeout_settlement_automatic
          #   voucher = Voucher.create!(date: @nepse_settlement_date)
          #   voucher.desc = description
          #   process_accounts(closeout_ledger, voucher, true, close_out_amount, description, cost_center_id, settlement_date)
          #   process_accounts(client_ledger, voucher, false, close_out_amount, description, cost_center_id, settlement_date)
          #   voucher.complete!
          #   transaction.closeout_settled = true
          #   voucher.save!
          # end

          transaction.save!
        end

        # return list of sales settlement ids
        # that track the file uploads for different settlement
        set_current_user = lambda { |l| l.current_user_id = @current_user.id }

        settlement_ids.each do |settlement_id|
          @nepse_settlement_ids << NepsePurchaseSettlement.find_or_create_by!(settlement_id: settlement_id, status: NepseSettlement.statuses[:complete], &set_current_user).id
        end
      end
    end
  end

  def extract_xls(_file)
    @error_message = "Please Upload a CSV file." and return
  end
end
