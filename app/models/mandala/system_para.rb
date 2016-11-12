class Mandala::SystemPara < ActiveRecord::Base
  self.table_name = "system_para"

  @ledgers_smartkhata_map = {
      "Purchase Commission" => :commission_purchase_ac,
      "Sales Commission" => :commission_sales_ac,
      "DP Fee/ Transfer" => :demat_fee_ac,
      "Nepse Purchase" => :nepse_purchase_ac,
      "Nepse Sales" => :nepse_sales_ac,
      # "Clearing Account"
      # "TDS" => :tds_ac,
      # "Cash" => :cash_ac,
      # "Close Out"
  }

  def self.smartkhata_mapped_system_ac
    system_para = self.first
    @ac_ledger_id_map = Hash.new

    return @ac_ledger_id_map if system_para.blank?

    @ledgers_smartkhata_map.each do |key, value|
      @ac_ledger_id_map[system_para[value]] = ::Ledger.find_by(name: key).id
    end
    @ac_ledger_id_map
  end


end