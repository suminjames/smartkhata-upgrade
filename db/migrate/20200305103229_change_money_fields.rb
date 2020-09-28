class ChangeMoneyFields < ActiveRecord::Migration[4.2]
  def up
    change_column :bank_payment_letters, :settlement_amount, :decimal, :precision => 12, :scale => 2
    change_column :bills, :net_amount, :decimal, :precision => 15, :scale => 2, default: 0.0
    change_column :bills, :balance_to_pay, :decimal, :precision => 15, :scale => 2, default: 0.0
    change_column :bills, :closeout_charge, :decimal, :precision => 15, :scale => 2, default: 0.0
    change_column :cheque_entries, :amount, :decimal, :precision => 15, :scale => 2
    change_column :closeouts, :rate, :decimal, :precision => 12, :scale => 2
    change_column :closeouts, :net_amount, :decimal, :precision => 15, :scale => 2
    change_column :isin_infos, :max, :decimal, :precision => 12, :scale => 2
    change_column :isin_infos, :min, :decimal, :precision => 12, :scale => 2
    change_column :isin_infos, :last_price, :decimal, :precision => 12, :scale => 2
    change_column :master_setup_commission_details, :start_amount, :decimal, :precision => 15, :scale => 2
    change_column :master_setup_commission_details, :limit_amount, :decimal, :precision => 15, :scale => 2
    change_column :nepse_chalans, :chalan_amount, :decimal, :precision => 15, :scale => 2
    change_column :particulars, :amount, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :share_rate, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :share_amount, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :commission_amount, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :dp_fee, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :cgt, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :bank_deposit, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :base_price, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :amount_receivable, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :closeout_amount, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :purchase_price, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :capital_gain, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :adjusted_sell_price, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :tds, :decimal, :precision => 12, :scale => 2
    change_column :share_transactions, :nepse_commission, :decimal, :precision => 12, :scale => 2
  end
end
