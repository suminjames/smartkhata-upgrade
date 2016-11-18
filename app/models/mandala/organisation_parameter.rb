# == Schema Information
#
# Table name: organisation_parameter
#
#  id              :integer          not null, primary key
#  org_name        :string
#  org_address     :string
#  contact_person  :string
#  broker_no       :string
#  off_tel_no      :string
#  res_tel_no      :string
#  fax             :string
#  mobile          :string
#  max_limit       :string
#  transaction_no  :string
#  job_no          :string
#  cash_deposit    :string
#  bank_guarantee  :string
#  pan_no          :string
#  email           :string
#  org_name_nepali :string
#  org_logo        :string
#

class Mandala::OrganisationParameter < ActiveRecord::Base
  self.table_name = "organisation_parameter"
end
