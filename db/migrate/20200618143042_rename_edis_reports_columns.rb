class RenameEdisReportsColumns < ActiveRecord::Migration
  def change
    rename_column :edis_reports, :settlement_id, :nepse_provisional_settlement_id
  end
end
