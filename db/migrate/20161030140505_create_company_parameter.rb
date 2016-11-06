class CreateCompanyParameter < ActiveRecord::Migration
  def change
    create_table :company_parameter do |t|
      t.string :company_code
      t.string :nepse_code
      t.string :company_name
      t.string :sector_code
      t.string :listing_date
      t.string :incorpyear
      t.string :company_address
      t.string :listing_bs_date
      t.string :no_of_share, limit: 8
      t.string :demat
    end
  end
end
