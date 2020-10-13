# == Schema Information
#
# Table name: broker_profiles
#
#  id            :integer          not null, primary key
#  broker_name   :string
#  broker_number :integer
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
#  ledger_id     :integer
#

class BrokerProfile < ApplicationRecord
  enum profile_type: { is_self_broker: 0, is_other_broker: 1 }
  enum locale: { english: 0, nepali: 1 }

  default_scope { is_other_broker }
  belongs_to :ledger

  validates :broker_name, :broker_number, :locale, presence: true

  validates :broker_number, numericality: { greater_than: 0 }
  validates :broker_number, uniqueness: { scope: :locale }

  before_validation :assign_default_locale

  # since we need to show the ledger and due to ajax we are not loading all the ledgers
  def ledger_map
    [ledger.presence].compact
  end

  private

  def strip_blanks(*fields)
    fields.each do |field|
      # self[field] = self.send(field).strip
      self.send("#{field}=", self.send(field).strip)
    end
  end

  def assign_default_locale
    self.locale ||= BrokerProfile.locales[:english]
  end
end
