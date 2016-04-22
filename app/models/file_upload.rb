class FileUpload < ActiveRecord::Base
	include ::Models::Updater
	FILES = { :unknown => 0, :floorsheet => 1 , :dpa5 => 2 }
end
