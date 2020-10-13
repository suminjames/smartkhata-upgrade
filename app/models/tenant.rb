# == Schema Information
#
# Table name: public.tenants
#
#  id                            :integer          not null, primary key
#  name                          :string
#  dp_id                         :string
#  full_name                     :string
#  phone_number                  :string
#  address                       :string
#  pan_number                    :string
#  fax_number                    :string
#  broker_code                   :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  closeout_settlement_automatic :boolean          default(FALSE)
#

class Tenant < ApplicationRecord
  attr_accessor :locale

  after_initialize :set_attr
  #
  # get tenant name from request
  #
  def self.name_from_request(request)
    request_host = request.host
    # remove demat. from the host as we are storing generic website
    # site address would be smartkhata.hostname.com
    request_host.slice! "smartkhata."
    tenant = Tenant.where(website: request_host).first
    tenant.present? ? tenant.name : nil
  end

  #
  # get tenant from request
  #
  def self.from_request(request)
    request_host = request.host
    # remove demat. from the host as we are storing generic website
    request_host.slice! "smartkhata."
    tenant = Tenant.where(website: request_host).first
    tenant
  end

  def broker_profile
    MasterSetup::BrokerProfile.where(
      locale: BrokerProfile.locales[@locale]
      # profile_type: BrokerProfile.profile_types[:is_self_broker],
    ).first
  end

  def dp_id
    broker_profile.try(:dp_code) || self[:dp_id]
  end

  def full_name
    broker_profile.try(:broker_name) || self[:full_name]
  end

  def phone_number
    broker_profile.try(:phone_number) || self[:phone_number]
  end

  def address
    broker_profile.try(:address) || self[:address]
  end

  def pan_number
    broker_profile.try(:pan_number) || self[:pan_number]
  end

  def fax_number
    broker_profile.try(:fax_number) || self[:fax_number]
  end

  def broker_code
    broker_profile.try(:broker_number) || self[:broker_code]
  end

  private

  def set_attr
    @locale = :english
  end
end
