class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|

      t.timestamps null: false
    end
  end
end
