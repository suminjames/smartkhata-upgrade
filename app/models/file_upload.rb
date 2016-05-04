# == Schema Information
#
# Table name: file_uploads
#
#  id          :integer          not null, primary key
#  file        :integer
#  report_date :date
#  ignore      :boolean          default("false")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class FileUpload < ActiveRecord::Base
	include ::Models::UpdaterWithBranch

  # resorted to nomenclature 'orders' instead of 'order', as order is a Active Record reserved keyword
  enum file_type: [:unknown, :floorsheet, :dpa5, :orders]

	# to keep track of the user who created and last updated the ledger
	belongs_to :creator,  class_name: 'User'
	belongs_to :updater,  class_name: 'User'
end
