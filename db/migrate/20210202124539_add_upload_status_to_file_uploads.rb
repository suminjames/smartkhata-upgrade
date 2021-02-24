class AddUploadStatusToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :status, :integer, default: 0
  end
end
