class AddColumnsToInterestParticulars < ActiveRecord::Migration
  def change
    add_column :interest_particulars, :interest, :integer
    add_column :interest_particulars, :date_bs, :string
  end
end
