class AddValueDatesToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :value_date, :date
  end
end
