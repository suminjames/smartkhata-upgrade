class EdisItemForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :file, :edis_items, :current_user_id
  validates_presence_of :file, :current_user_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end


  def import_file
    self.edis_items = []
    if file.present?
      converter = lambda { |header| header.gsub(/( )/, '_')&.downcase }
      CSV.read(file.path, headers: true,  header_converters: converter).each do |record|
        # if settlement_id.to_s != record["settlement_id"]
        #   self.errors.add(:file, "Contains invalid settlement id")
        #   break
        # end
        sale_settlement = SalesSettlement.where(contract_no: record['contract_number']).first
        if sale_settlement.blank?
          self.errors.add(:file, 'CMO1 has not been uploaded for these records')
          break
        end

        item = EdisItem.where.not(reference_id: nil).where(reference_id: record['id']).first
        # skip already success state
        next if item.present?  && item.status == EdisItem.statuses[:success]

        item = EdisItem.new if item.blank?
        item.assign_attributes(record.to_h.except("wacc(cns)", "s.n","status", "id", "settlement_id"))
        item.reference_id = record['id']
        item.current_user_id = current_user_id
        item.status = EdisItem.statuses[:pending]
        item.reason_code = EdisItem.reason_codes[:regular]
        item.sales_settlement_id = sale_settlement.id

        unless item.valid?
          self.errors.add(:file, "Contains invalid records")
          break
        end

        self.edis_items << item
      end
      self.edis_items.each(&:save!)
      true
    end
  end


  def persisted?
    false
  end
end
