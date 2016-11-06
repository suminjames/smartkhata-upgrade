class CreateFiscalYearPara < ActiveRecord::Migration
  def change
    create_table :fiscal_year_para do |t|
      t.string :fiscal_year
      t.string :fy_start_date
      t.string :fy_end_date
      t.string :entered_by
      t.string :entered_date
      t.string :year_end
      t.string :status
      t.string :fy_start_date_bs
      t.string :fy_end_date_bs
    end
  end
end
