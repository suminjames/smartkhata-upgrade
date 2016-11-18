# == Schema Information
#
# Table name: mobile_message
#
#  id               :integer          not null, primary key
#  customer_code    :string
#  mobile_no        :string
#  transaction_date :string
#  message_date     :string
#  bill_no          :string
#  message          :string
#  message_type     :string
#

class Mandala::MobileMessage < ActiveRecord::Base
  self.table_name = "mobile_message"
end
