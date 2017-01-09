# == Schema Information
#
# Table name: public.tenants
#
#  id           :integer          not null, primary key
#  name         :string
#  dp_id        :string
#  full_name    :string
#  phone_number :string
#  address      :string
#  pan_number   :string
#  fax_number   :string
#  broker_code  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#



class Tenant < ActiveRecord::Base
  has_many :broker_profiles

  attr_accessor :locale

  after_initialize :set_attr

  def broker_profile
    broker_profiles.unscoped.where(
        locale: BrokerProfile.locales[@locale],
        profile_type: BrokerProfile.profile_types[:is_self_broker]
    ).first
  end

  def dp_id
    broker_profile.try(:dp_code)
  end

  def full_name
    broker_profile.try(:broker_name)
  end

  def phone_number
    broker_profile.try(:phone_number)
  end

  def address
    broker_profile.try(:address)
  end

  def pan_number
    broker_profile.try(:pan_number)
  end

  def fax_number
    broker_profile.try(:fax_number)
  end

  def broker_code
    broker_profile.try(:broker_number)
  end

  private
  def set_attr
    @locale = :english
  end

end
