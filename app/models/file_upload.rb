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

class FileUpload < ActiveRecord::Base
  # include Auditable
  include ::Models::Updater

  # resorted to nomenclature 'orders' instead of 'order', as order is a Active Record reserved keyword
  enum file_type: [:unknown, :floorsheet, :dpa5, :orders]
  enum status: { processed: 0, processing: 1, errored: 2 }

  after_save :patch_particulars


  def patch_particulars
    if persisted? && value_date_changed?
      FloorsheetValueDateJob.perform_later(report_date.to_s, value_date.to_s)
    end
  end
end
