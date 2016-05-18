# == Schema Information
#
# Table name: calendars
#
#  id         :integer          not null, primary key
#  year       :integer          not null
#  month      :integer          not null
#  day        :integer          not null
#  is_holiday :boolean          default("false")
#  date_type  :integer          not null
#  remarks    :text
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Calendar < ActiveRecord::Base
  include ::Models::Updater
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
end
