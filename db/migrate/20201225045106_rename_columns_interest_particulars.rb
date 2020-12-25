class RenameColumnsInterestParticulars < ActiveRecord::Migration
  def self.up
    rename_column :interest_particulars, :amount, :principle
  end
  
  def self.down
    rename_column :interest_particulars, :principle, :amount
  end
end
