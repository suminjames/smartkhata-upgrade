class RemoveEdisReportFromEdisItems < ActiveRecord::Migration
  def change
    remove_reference :edis_items, :edis_report, index: true
    add_reference :edis_items, :sales_settlement, index: true, foreign_key: true
  end
end
