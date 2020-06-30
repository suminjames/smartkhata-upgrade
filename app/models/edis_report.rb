class EdisReport < ActiveRecord::Base
  # has_many :edis_items, dependent: :destroy, inverse_of: :edis_report

  belongs_to :nepse_provisional_settlement
  has_many :edis_items, through: :nepse_provisional_settlement

  attr_accessor :current_user_id
  # accepts_nested_attributes_for :edis_items

  validates :business_date, :nepse_provisional_settlement_id, presence: true
  validate :pending_for_business_date, on: :create

  enum status: { available: 0, blocked: 1 }

  delegate :settlement_id, to: :nepse_provisional_settlement, allow_nil: true

  before_validation :assign_sequence_number, on: :create

  def assign_sequence_number
    self.sequence_number = (EdisReport.where(business_date:  business_date).maximum(:sequence_number) || 0) + 1
  end


  def pending_for_business_date
    if EdisReport.blocked.where(business_date: business_date).any?
      errors.add(:business_date, 'Pending CNS response file for the day')
    end
  end

  def available_edis_items
    unless edis_items.available_for_cns.any?
      errors.add(:nepse_provisional_settlement_id, 'Please upload Purchase Report first')
    end
  end

  def csv_report(tenant)
    cm_id = tenant.broker_code
    # cm_id = 48
    #
    unless valid?
      return [nil, true] if errors[:nepse_provisional_settlement_id].present?
      return [nil, nil]
    end

    items, total_items, total_quantity = averaged_edis_items

    file_name = download_file_name(cm_id,business_date)
    header = header(cm_id, total_items, total_quantity, business_date)

    csv_data = CSV.generate do |csv|
      csv << [header]
      items.each do |record|
        csv << [record_details(record)]
      end
    end
    update(status: EdisReport.statuses[:blocked], file_name: file_name)
    return csv_data, file_name
  end

  def averaged_edis_items
    items = edis_items.available_for_cns.group_by(&:contract_number)

    new_array = []
    total_quantity = 0
    total_items = 0

    items.each do |k, value|
      record = value.first
      if value.size != 1
        data = value.reduce({})  do |hash, record|
          hash[:quantity] = (hash[:quantity]||0)+ record.quantity
          hash[:wacc] = (hash[:wacc] || 0) + (record.quantity * record.wacc)
          hash
        end

        record.quantity = data[:quantity]
        record.wacc = (data[:wacc]/data[:quantity]).round(2)
      end
      new_array.push(record)
      total_items += 1
      total_quantity += record.quantity
    end
    return new_array, total_items, total_quantity
  end

  def download_file_name(cm_id, business_date)
    "CGT#{format_digits(cm_id, 3)}#{business_date.strftime('%d%m%Y')}.#{format_digits(sequence_number, 2)}"
  end

  def header(cm_id, total_items, total_quantity, business_date)
    date = business_date.strftime('%d%m%Y')
    count = format_digits(total_items, 6)
    settlementid = format_digits(self.settlement_id, 13)
    cm_id = format_digits(cm_id, 15)
    total = format_digits(total_quantity,16)
    [date,count,settlementid,cm_id,total].join('')
  end

  def record_details record
    settlementid = format_digits(record.settlement_id,13)
    contract_number = format_digits(record.contract_number,16)
    quantity = format_digits(record.quantity, 11)
    rate =  format_digits(record.wacc.round(2) * 1000, 16)
    reason_code = format_digits(record.read_attribute('reason_code'), 2)
    [settlementid, contract_number, quantity, rate, reason_code].join('')
  end


  def format_digits(integer, places)
    return integer.to_s if places <= 0
    "%0#{places}i" % integer.to_i
  end
end
