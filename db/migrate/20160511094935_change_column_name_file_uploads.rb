class ChangeColumnNameFileUploads < ActiveRecord::Migration
  def change
    rename_column :file_uploads, :file, :file_type
  end
end
