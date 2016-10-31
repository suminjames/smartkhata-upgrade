class CreateFiscalYearPara < ActiveRecord::Migration
  def change
    create_table :fiscal_year_para do |t|
      t.string :fiscal_year
      t.date :fy_start_date
      t.date :fy_end_date
      t.string :entered_by
      t.date :entered_date
      t.string :year_end
      t.string :status
      t.string :fy_start_date_bs
      t.string :fy_end_date_bs
    end
  end
end
