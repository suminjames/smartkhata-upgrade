# == Schema Information
#
# Table name: closeouts
#
#  id                :integer          not null, primary key
#  settlement_id     :decimal(18, )
#  contract_number   :decimal(18, )
#  seller_cm         :integer
#  seller_client     :string
#  buyer_cm          :integer
#  buyer_client      :string
#  isin              :string
#  scrip_name        :string
#  quantity          :integer
#  shortage_quantity :integer
#  rate              :decimal(15, 4)   default("0")
#  net_amount        :decimal(15, 4)   default("0")
#  closeout_type     :integer
#  creator_id        :integer
#  updater_id        :integer
#  branch_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#



class Closeout < ActiveRecord::Base
  include ::Models::UpdaterWithBranch
  enum closeout_type: [:debit, :credit]

  # validates :employee_id, uniqueness: { scope: :area_id }
  validates :net_amount, presence: true
end
