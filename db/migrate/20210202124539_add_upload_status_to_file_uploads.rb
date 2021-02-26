class AddUploadStatusToFileUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :file_uploads, :status, :integer, default: 0
  end
end
