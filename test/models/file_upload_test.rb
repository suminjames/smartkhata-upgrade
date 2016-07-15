# == Schema Information
#
# Table name: file_uploads
#
#  id          :integer          not null, primary key
#  file_type   :integer
#  report_date :date
#  ignore      :boolean          default("false")
#  creator_id  :integer
#  updater_id  :integer
#  branch_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class FileUploadTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
