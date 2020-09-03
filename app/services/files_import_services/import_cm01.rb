class FilesImportServices::ImportCm01 < ImportFile

  include ApplicationHelper

  attr_reader :skip_missing
  def initialize(file, skip_missing = false)
    super(file)
    @skip_missing = skip_missing
  end

  def process
    open_file(@file)
    ActiveRecord::Base.transaction do
      provisional_settlements = {}

      @processed_data.each do |hash|
        hash = hash.deep_stringify_keys!
        settlement_id = hash['Sett_ID'].to_i
        contract_no = hash['ContractNo'].to_i
        tradestartdate = hash['TradeStartDate']
        tradeenddate = hash['TradeStartDate']
        secpayindt = hash['SecPayInDt']
        secpayoutdt = hash['SecPayOutDt']
        scriptshortname = hash['ScriptshortName']
        scriptnumber = hash['ScriptNumber']
        clientcode = hash['ClientCode']
        quantity = hash['Quantity'].to_i
        cmid = hash['CMID'].to_i
        sellerodrno = hash['SellerOdrNo'].to_i

        provisional_settlement = provisional_settlements[settlement_id]
        if provisional_settlement.blank?
          provisional_settlement = NepseProvisionalSettlement.find_or_create_by!(settlement_id: settlement_id, status: NepseSettlement.statuses[:complete])
          provisional_settlements[settlement_id] = provisional_settlement
        end

        share_transaction = ShareTransaction.selling.where(contract_no: contract_no).first

        if share_transaction.blank?
          next if  skip_missing

          import_error("The file you have uploaded contains contract number  #{contract_no} which is not in system")
          raise ActiveRecord::Rollback
          break
        end


        SalesSettlement.find_or_create_by!(settlement_id: settlement_id, contract_no: contract_no) do |ss|
          ss.share_transaction_id = share_transaction.id
          ss.nepse_provisional_settlement_id = provisional_settlement.id
          ss.tradestartdate = tradestartdate
          ss.tradeenddate = tradeenddate
          ss.secpayindt = secpayindt
          ss.secpayoutdt = secpayoutdt
          ss.scriptshortname = scriptshortname
          ss.scriptnumber = scriptnumber
          ss.clientcode = clientcode
          ss.quantity = quantity
          ss.cmid = cmid
          ss.sellerodrno = sellerodrno
          ss.save!
        end
      end
    end
  end

  def extract_xls(file)
    @error_message = "Please Upload a CSV file."
  end
end
