class EdisItem < ApplicationRecord
  include Auditable
  include Models::Updater

  belongs_to :sales_settlement, inverse_of: :edis_items
  attr_accessor :skip_edis_report_update, :split_options, :splitted_records

  validates :contract_number, :quantity, :scrip, :boid, :client_code, :wacc, :settlement_date, :reason_code, presence: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :wacc, numericality: { greater_than: 0 }

  validate :contract_number_exists, :client_code_exists
  validate :quantity_less_than_transaction

  validate :valid_merge_rebate
  validate :valid_split_options

  enum reason_code: { merger: 18, regular: 19 }
  enum status: { pending: 0, success: 1, error: 2 }

  scope :available_for_cns, -> { where.not(status: EdisItem.statuses[:success]) }

  delegate :settlement_id, to: :sales_settlement, allow_nil: true
  # before_validation :set_default_reason_code
  before_save :change_status, if: :data_changed?

  after_update :split_record, if: :valid_for_split?

  def change_status
    self.status = :pending
  end

  def data_changed?
    changed? && (wacc_changed? || quantity_changed?)
  end

  def valid_merge_rebate
    if merge?
      transaction_date = sales_settlement.share_transaction&.date
      errors.add(:reason_code, 'Merge Rebate is not applicable') unless MergeRebate.where('rebate_start <= ? and rebate_end >= ?', transaction_date, transaction_date).any?
    end
  end

  def valid_split_options
    if valid_for_split?
      split_options.each do |option|
        record = self.dup
        record.split_options = nil
        record.quantity = option[:quantity]
        record.wacc = option[:wacc]
        record.reason_code = option[:reason_code]

        unless record.valid?
          errors.add(:splitted_records, "Invalid Records, please verify the Reason Code")
          break
        end
      end
    end
  end

  def client_code_exists
    if ClientAccount.where(nepse_code: client_code.upcase).any?
      self.boid = ClientAccount.where(nepse_code: client_code.upcase).first&.boid if self.boid.blank?
    else
      errors.add(:client_code, 'invalid')
    end
  end

  def contract_number_exists
    if ShareTransaction.selling.where(contract_no: contract_number).any?
      if self.sales_settlement_id.blank?
        sales_settlement = SalesSettlement.where(contract_no: contract_number).first
        if sales_settlement.blank?
          errors.add(:contract_number, "no cm records yet!")
        else
          self.sales_settlement_id = sales_settlement.id
          share_transaction = ShareTransaction.selling.where(contract_no: contract_number).first
          client_account = share_transaction.client_account
          isin_info = share_transaction.isin_info
          self.boid ||= client_account.object_id
          self.client_code ||= client_account.nepse_code
          self.scrip ||= isin_info.isin
        end
      end
    else
      errors.add(:contract_number, 'invalid')
    end
  end

  # takes care of scrip and quantity
  def quantity_less_than_transaction
    errors.add(:quantity, "does not match") if ((calculated_quantity || 0) + EdisItem.where.not(id: id, reference_id: reference_id).where(contract_number: contract_number).sum(:quantity)) > ShareTransaction.selling.includes(:isin_info).where(contract_no: contract_number, isin_infos: { isin: scrip }).sum(:quantity)
  end

  def calculated_quantity
    if valid_for_split?
      quantity + split_options.map { |s| s[:quantity].to_f }.reduce(0, :+)
    else
      quantity
    end
  end

  def valid_for_split?
    split_options.present? && split_options.is_a?(Array)
  end

  def split_record
    self.splitted_records = []
    split_options.each do |option|
      record = self.dup
      record.split_options = nil
      record.quantity = option[:quantity]
      record.wacc = option[:wacc]
      record.reason_code = option[:reason_code]
      record.save!
      self.splitted_records << record
    end
    self.splitted_records
  end
end
