class FileUpload < ActiveRecord::Base
	include ::Models::UpdaterWithBranch
	FILES = { :unknown => 0, :floorsheet => 1 , :dpa5 => 2 }
	# to keep track of the user who created and last updated the ledger
	belongs_to :creator,  class_name: 'User'
	belongs_to :updater,  class_name: 'User'
end
