class MergeRebate < ActiveRecord::Base
  before_validation :process_scrip
  validates :scrip, :rebate_start, :rebate_end, presence: true
  validates :scrip, uniqueness: true

  def process_scrip
    self.scrip = self.scrip.strip.upcase if self.scrip.present?
  end
end
