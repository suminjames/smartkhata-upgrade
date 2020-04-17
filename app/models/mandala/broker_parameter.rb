# == Schema Information
#
# Table name: broker_parameter
#
#  id             :integer          not null, primary key
#  org_name       :string
#  org_address    :string
#  contact_person :string
#  broker_no      :string
#  off_tel_no     :string
#  res_tel_no     :string
#  fax            :string
#  mobile         :string
#

class Mandala::BrokerParameter < ApplicationRecord
  self.table_name = "broker_parameter"
end
