class AddColumnsToEdisReports < ActiveRecord::Migration
  def change
    add_column :edis_reports, :business_date, :date, index: true
    add_column :edis_reports, :file_name, :string, index: true
  end
end
