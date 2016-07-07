# encoding: utf-8
# TODO how to remove the code repetition
module Models::UpdaterWithFyCode

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator, :add_fy_code
      before_save :set_updater

      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'

      scope :by_fy_code, -> (fy_code) { where(fy_code: fy_code)}
    end
  end

  private

  def set_updater
    self.updater_id = UserSession.id
  end

  def set_creator
    self.creator_id = UserSession.id
  end

  def add_fy_code
    self.fy_code ||= get_fy_code
  end
end