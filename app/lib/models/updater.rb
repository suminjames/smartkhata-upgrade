# encoding: utf-8
module Models::Updater
  def self.included(base)
    base.instance_eval do
      before_validation :set_creator, :set_updater

      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User', optional: true
      belongs_to :updater,  class_name: 'User', optional: true

      attr_accessor :current_user_id
    end
  end

  private

  def set_updater
    self.updater_id = current_user_id
  end

  def set_creator
    self.creator_id ||= current_user_id
  end
end
