class EdisReportForm
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
      uploaded_filename = File.basename(file.original_filename, ".out")
      response_record = EdisReport.find_by(file_name: uploaded_filename)
      if response_record.present?
        CSV.read(file.path).each do |record|
          edis_items = NepseProvisionalSettlement.where(settlement_id: record[1]).first.edis_items.where(contract_number: record[2]) rescue []
          edis_items.each do |item|
            item.status = (record[6].to_i == 0 && record[7].downcase == 'success') ? EdisItem.statuses[:success] : EdisItem.statuses[:error]
            item.status_message = record[7]
            self.edis_items << item
          end
        end
        self.edis_items.each(&:save!)
        response_record.available!
      else
        self.errors.add(:file, 'No record found for uploaded file!')
      end
    end
  end

  def persisted?
    false
  end
end
