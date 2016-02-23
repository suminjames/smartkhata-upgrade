class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
    	t.integer :file
    	t.date	:report_date
    	t.boolean :ignore, default: false
      t.timestamps null: false
    end
  end
end
