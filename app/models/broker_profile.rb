# == Schema Information
#
# Table name: broker_profiles
#
#  id            :integer          not null, primary key
#  broker_name   :string
#  broker_number :string
#  address       :string
#  dp_code       :integer
#  phone_number  :string
#  fax_number    :string
#  email         :string
#  pan_number    :string
#  profile_type  :integer
#  locale        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class BrokerProfile < ActiveRecord::Base
  enum profile_type: [:is_self_broker, :is_other_broker]
  enum locale: [:english, :nepali]

  default_scope { is_other_broker }

  before_validation -> { strip_blanks :broker_name, :broker_number }

  validates_presence_of :broker_name, :broker_number, :address, :phone_number, :fax_number, :pan_number, :locale
  validates :broker_number, uniqueness: { scope: :locale }

  private
  def strip_blanks(*fields)
    fields.each do |field|
      # self[field] = self.send(field).strip
      self.send("#{field}=", self.send(field).strip)
    end
  end
end
