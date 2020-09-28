# == Schema Information
#
# Table name: voucher
#
#  id                    :integer          not null, primary key
#  voucher_no            :string
#  voucher_code          :string
#  serial_no             :string
#  voucher_date          :string
#  bs_date               :string
#  dr_ac_code            :string
#  dr_sub_code           :string
#  cr_ac_code            :string
#  cr_sub_code           :string
#  narration             :string
#  paid_to_received_from :string
#  cheque_no             :string
#  prepared_by           :string
#  checked_by            :string
#  approved_by           :string
#  authorized_by         :string
#  transaction_no        :string
#  fiscal_year           :string
#  bill_no               :string
#  posted_by             :string
#  voucher_id            :integer
#  migration_completed   :boolean          default(FALSE)
#  voucher_date_parsed   :date
#

class Mandala::Voucher < ActiveRecord::Base

  include FiscalYearModule

  # validates_uniqueness_of :voucher_no, :scope => [ :voucher_code, :fiscal_year ]

  self.table_name = "voucher"
  belongs_to :voucher

  def voucher_details
    Mandala::VoucherDetail.where(voucher_no: self.voucher_no, voucher_code: self.voucher_code)
  end

  def ledgers
    Mandala::Ledger.where(voucher_no: self.voucher_no, voucher_code: self.voucher_code)
  end

  def modified_ledgers
    ledgers = []
    mandala_data = self.ledgers
    ledgers = mandala_data
    ledgers
  end

  def receipt_payments
    Mandala::ReceiptPaymentSlip.where(voucher_no: self.voucher_no, voucher_code: self.voucher_code)
  end

  scope :jvr, -> { where(voucher_code: 'JVR') }
  scope :rcp, -> { where(voucher_code: 'RCP') }
  scope :pvb, -> { where(voucher_code: 'PVR') }
  scope :rcb, -> { where(voucher_code: 'RCB') }
  scope :pending, -> {where(migration_completed: false)}

  def fy_code
    get_fy_code_from_fiscal_year(fiscal_year)
  end

  def pending

  end
  def new_smartkhata_voucher
    fy_code = get_fy_code
    fy_code ||= get_fy_code_from_fiscal_year(fiscal_year)

    ::Voucher.new({
        fy_code: fy_code,
        voucher_number: get_fy_stripped_voucher_no,
        voucher_type: voucher_mapping,
        date: Date.parse(voucher_date),
        date_bs: bs_date,
        desc: narration,
        voucher_status: :complete })
  end

  def voucher_mapping
    vouchers = {
        'JVR' => :journal,
        'PMT' => :payment,
        'RCV' => :receipt,
        'CVR' => :contra,
        'PVR' => :payment_cash,
        'RCP' => :receipt_cash,
        'PVB' => :payment_bank,
        'RCB' => :receipt_bank,
        'CDB' => :receipt_bank_deposit
    }
    ::Voucher.voucher_types[vouchers[self.voucher_code]]
  end

  def get_fy_stripped_voucher_no
    voucher_info = voucher_no.split('-')
    if voucher_info.size > 1
      return voucher_info[1]
    else
      return voucher_info[0]
    end
  end

  def get_fy_code
    voucher_info = voucher_no.split('-')
    if voucher_info.size > 1
      return voucher_info[0]
    end
    return nil
  end
end
