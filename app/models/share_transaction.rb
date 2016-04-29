class ShareTransaction < ActiveRecord::Base

  include ::Models::UpdaterWithBranch
  belongs_to :bill
  belongs_to :voucher
  belongs_to :isin_info
  belongs_to :client_account

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  enum transaction_type: [ :buy, :sell ]
  # before_update :calculate_cgt
  validates :base_price, numericality: true
  scope :find_by_date, -> (date) { where(
    :date=> date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(
      :date=> date_from.beginning_of_day..date_to.end_of_day) }

  # used for inventory (it selects only those which are not cancelled and have more than 1 share quantity)
  scope :not_cancelled, -> { where(deleted_at: nil).where.not(quantity: 0) }

  # used for bill ( it eradicates only with deal cancelled)
  scope :not_cancelled_for_bill, -> { where(deleted_at: nil) }

  scope :cancelled, -> { where.not(deleted_at: nil) }

 def do_as_per_params (params)
  # TODO
 end
# instead of deleting, indicate the user requested a delete & timestamp it
 def soft_delete
   update_attribute(:deleted_at, Time.current)
 end

 def soft_undelete
   update_attribute(:deleted_at, nil)
 end

  def update_with_base_price(params)
    self.update(params)
    self.calculate_cgt
    self
  end
  def calculate_cgt
    old_cgt = self.cgt
    if self.base_price?
      tax_rate = self.client_account.individual? ? 0.05 : 0.1
      # tax_rate = 0.01
      self.cgt = (self.share_rate - self.base_price) * tax_rate * self.quantity
      self.net_amount = self.net_amount - old_cgt + self.cgt
    end
  end

  def deal_cancelled
    self.deleted_at.present?
  end
end
