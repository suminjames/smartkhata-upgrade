class AddValueDatesToFileUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :file_uploads, :value_date, :date
  end
end
