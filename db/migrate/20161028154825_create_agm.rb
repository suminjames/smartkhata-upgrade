class CreateAgm < ActiveRecord::Migration[4.2]
  def change
    create_table :agm do |t|
      t.string :company_code
      t.string :agm_date
      t.string :book_close_date
      t.string :agm_place
      t.string :divident_pct
      t.string :bonus_pct
      t.string :right_share
      t.string :fiscal_year
    end
  end
end
