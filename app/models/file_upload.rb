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
	FILES = { :unknown => 0, :floorsheet => 1 , :dpa5 => 2 }
end
