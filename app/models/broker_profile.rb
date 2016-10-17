class BrokerProfile < ActiveRecord::Base
  enum profile_type: [:is_self_broker, :is_other_broker]
  enum locale: [:english, :nepali]

  before_validation -> { strip_blanks :broker_name, :broker_number }

  # validates_presence_of :broker_name, :broker_number, :address, :phone_number, :fax_number, :pan_number, :locale
  validates :broker_number, uniqueness: { scope: :locale }

  private
  def strip_blanks(*fields)
    fields.each do |field|
      # self[field] = self.send(field).strip
      self.send("#{field}=", self.send(field).strip)
    end
  end
end