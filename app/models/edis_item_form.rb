class EdisItemForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :file, :current_user_id, :skip_invalid_transactions
  validates_presence_of :file, :current_user_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def skip_invalid_transactions?
    skip_invalid_transactions == '1'
  end


  def import_file
    if file.present?
      converter = lambda { |header| header.gsub(/( )/, '_')&.downcase }
      begin
        CSV.read(file.path, headers: true,  header_converters: converter).each do |record|
          sale_settlement = SalesSettlement.where(contract_no: record['contract_number']).first
          if sale_settlement.blank?
            next if skip_invalid_transactions?

            self.errors.add(:file, 'CMO1 has not been uploaded for these records')
            break
          end
          # skip those without wacc, manual wacc
          next if  record['wacc(cns)'].to_i !=0 || record['wacc'].blank? || record['wacc'].to_i == 0

          # skip those with missing status
          next if skip_invalid_transactions? && ['MISSED', 'Overdue  due to Insufficient balance'].include?(record['status'])

          item = EdisItem.where.not(reference_id: nil).where(reference_id: record['id']).first
          # skip already success state
          next if item.present?  && item.success?

          item = EdisItem.new if item.blank?
          item.assign_attributes(record.to_h.except("wacc(cns)", "s.n","status", "id", "settlement_id"))
          item.reference_id = record['id']
          item.current_user_id = current_user_id
          item.status = EdisItem.statuses[:pending]
          item.reason_code = EdisItem.reason_codes[:regular]
          item.sales_settlement_id = sale_settlement.id

          unless item.save
            next if skip_invalid_transactions?

            self.errors.add(:file, "Contains invalid records for #{item.contract_number}, Error: #{item.errors.full_messages.join(",")}")
            break
          end
        end
      rescue
        self.errors.add(:file, "Another file is being processed. Try again later")
      end
      true
    end
  end


  def persisted?
    false
  end
end
