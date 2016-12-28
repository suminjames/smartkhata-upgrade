# == Schema Information
#
# Table name: customer_registration_detail
#
#  id              :integer          not null, primary key
#  customer_code   :string
#  group_code      :string
#  group_name      :string
#  director_name   :string
#  designation     :string
#  vdc_mp_smp      :string
#  vdc_mp_smp_name :string
#  tole            :string
#  ward_no         :string
#  phone_no        :string
#  email           :string
#  skype_id        :string
#

class Mandala::CustomerRegistrationDetail < ActiveRecord::Base
  self.table_name = "customer_registration_detail"
end
