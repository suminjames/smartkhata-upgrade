class RenameEdisReportsColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :edis_reports, :settlement_id, :nepse_provisional_settlement_id
  end
end
