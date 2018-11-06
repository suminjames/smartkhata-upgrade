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

# Note:
# - there should not be more than two MasterSetup::BrokerProfile (one for each locale) for a tenant.

class MasterSetup::BrokerProfile < BrokerProfile
  MAXIMUM_RECORDS_ALLOWED = 2
  validate :single_locale_record

  self.default_scopes = []
  default_scope { is_self_broker }

  def self.has_profile_in(locale)
    self.where(locale: BrokerProfile.locales[locale]).count > 0
  end

  def self.has_maximum_records?
    self.all.size >= MAXIMUM_RECORDS_ALLOWED
  end

  def single_locale_record
    if self.class.where(locale: MasterSetup::BrokerProfile.locales[self.locale]).size > 0
      errors.add(:locale, "There is already another Broker Profile for #{self.locale} locale.")
    end
  end

end
