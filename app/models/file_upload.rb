# == Schema Information
#
# Table name: file_uploads
#
#  id          :integer          not null, primary key
#  file_type   :integer
#  report_date :date
#  ignore      :boolean          default(FALSE)
#  creator_id  :integer
#  updater_id  :integer
#  branch_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class FileUpload < ApplicationRecord
  include Auditable
  include ::Models::Updater

  # resorted to nomenclature 'orders' instead of 'order', as order is a Active Record reserved keyword
  enum file_type: [:unknown, :floorsheet, :dpa5, :orders]
end
