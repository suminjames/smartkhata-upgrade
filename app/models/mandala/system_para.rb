# == Schema Information
#
# Table name: system_para
#
#  id                      :integer          not null, primary key
#  nepse_purchase_ac       :string
#  nepse_sales_ac          :string
#  commission_purchase_ac  :string
#  commission_sales_ac     :string
#  name_transfer_rate      :string
#  nepse_capital_ac        :string
#  extra_commission_charge :string
#  voucher_tag             :string
#  voucher_code            :string
#  name_transfer_ac        :string
#  cash_ac                 :string
#  tds_ac                  :string
#  sebo_ac                 :string
#  demat_fee               :string
#  demat_fee_ac            :string
#  cds_fee_ac              :string
#  sebon_fee_ac            :string
#  sebon_regularity_fee_ac :string
#

class Mandala::SystemPara < ApplicationRecord
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
