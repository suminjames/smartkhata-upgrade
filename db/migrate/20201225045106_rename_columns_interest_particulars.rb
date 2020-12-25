class RenameColumnsInterestParticulars < ActiveRecord::Migration
  def self.up
    rename_column :interest_particulars, :amount, :interest_particulars
  end
  
  def self.down
    rename_column :interest_particulars, :interest_particulars, :amount
  end
end
