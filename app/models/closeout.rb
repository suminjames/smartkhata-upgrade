class Closeout < ActiveRecord::Base
  include ::Models::Updater
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
  enum closeout_type: [:debit, :credit]

  # validates :employee_id, uniqueness: { scope: :area_id }
  validates :net_amount, presence: true
end
