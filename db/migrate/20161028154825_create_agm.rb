class CreateAgm < ActiveRecord::Migration
  def change
    create_table :agm do |t|
      t.string :company_code
      t.date :agm_date
      t.date :book_close_date
      t.string :agm_place
      t.float :divident_pct
      t.float :bonus_pct
      t.float :right_share
      t.string :fiscal_year
    end
  end
end
