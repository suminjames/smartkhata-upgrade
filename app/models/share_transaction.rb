# == Schema Information
#
# Table name: share_transactions
#
#  id                  :integer          not null, primary key
#  contract_no         :decimal(18, )
#  buyer               :integer
#  seller              :integer
#  raw_quantity        :integer
#  quantity            :integer
#  share_rate          :decimal(10, 4)   default("0")
#  share_amount        :decimal(15, 4)   default("0")
#  sebo                :decimal(15, 4)   default("0")
#  commission_rate     :string
#  commission_amount   :decimal(15, 4)   default("0")
#  dp_fee              :decimal(15, 4)   default("0")
#  cgt                 :decimal(15, 4)   default("0")
#  net_amount          :decimal(15, 4)   default("0")
#  bank_deposit        :decimal(15, 4)   default("0")
#  transaction_type    :integer
#  settlement_id       :decimal(18, )
#  base_price          :decimal(15, 4)   default("0")
#  amount_receivable   :decimal(15, 4)   default("0")
#  closeout_amount     :decimal(15, 4)   default("0")
#  remarks             :string
#  purchase_price      :decimal(15, 4)   default("0")
#  capital_gain        :decimal(15, 4)   default("0")
#  adjusted_sell_price :decimal(15, 4)   default("0")
#  date                :date
#  deleted_at          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  nepse_chalan_id     :integer
#  creator_id          :integer
#  updater_id          :integer
#  branch_id           :integer
#  voucher_id          :integer
#  bill_id             :integer
#  client_account_id   :integer
#  isin_info_id        :integer
#

class ShareTransaction < ActiveRecord::Base

  include ::Models::UpdaterWithBranch
  belongs_to :bill
  belongs_to :voucher
  belongs_to :isin_info
  belongs_to :client_account
  belongs_to :nepse_chalan

  enum transaction_type: [ :buying, :selling ]
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
  scope :without_chalan, -> {where(deleted_at: nil).where.not(quantity: 0).where(nepse_chalan_id: nil)}

  scope :above_threshold, ->(date) { not_cancelled.find_by_date(date).where("net_amount >= ?", 1000000)}

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
