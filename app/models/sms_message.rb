# == Schema Information
#
# Table name: sms_messages
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'net/http'
class SmsMessage < ActiveRecord::Base

  @tag = 'B'
  @access_code = 'M210DAF977'
  @username = 'danpheit'
  @password = 'Danfe!23'

  # Reply code:
  #  0 = Error
  #  1 = successfully record accept to send.
  #  2 = Invalid tag.
  #  3 = Missing Parameter.
  #  4 = Null parameter.
  #  5 = Invalid access code.
  #  6 = Invalid Username / Password.
  #  7 = Message length exceed more than 255 characters.
  #  8 = Invalid values in parameters like date incorrect format, mobile != 13 digits
  #  9 = Balance not enough.


  def self.check_balance
    result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=BQ' + '&ac=' + @access_code + '&u=' + @username + '&p=' + @password)).body
    # TODO(sarojk): Check for condition where the server is down or server returns something other than expected result pattern
    # Expected result pattern-ish: "Balance remaining = 93.00"
    result.split('=')[1].strip.to_f
  end

  def self.send_hello_world(current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    @date_time = DateTime.now.to_s(:db)
    @mobile_number = '9851153385'
    @message = 'Hello World, from DIT'
    self.push_sms
    Apartment::Tenant.switch!('public')
  end

  # The reply_code is a string
  def self.push_sms
    reply_code = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + @tag + '&ac=' + @access_code + '&dt=' + @date_time + '&mob=' + @mobile_number + '&msg=' + @message + '&u=' + @username + '&p=' + @password)).body
  end

  def self.send_bill_sms(transaction_message_id, current_tenant_id )
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    self.date_time
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    transaction_message.sms_queued!
    self.message = transaction_message.sms_message
    self.date_time
    self.mobile_number = transaction_message.client_account.messageable_phone_number
    reply_code = self.push_sms
    if reply_code == '1'
      transaction_message.increase_sent_sms_count!
      transaction_message.sms_sent!
    else
      transaction_message.sms_unsent!
    end
    Apartment::Tenant.switch!('public')
  end

  # Encodes the message specifically encoding the (white)space
  def self.message= (msg)
    @message = msg.gsub(' ', '%20')
  end

  def self.mobile_number= (number)
    @mobile_number = self.manipulate_phone_number(number)
  end

  def self.date_time
    @date_time = DateTime.now.to_s(:db)
  end

  # Strip any non-digit character
  # If the number doesn't start with 977, prepend 977.
  def self.manipulate_phone_number(number)
    number = number.to_s.gsub(/\D/, '')
    number = number.prepend('977') unless number.start_with?('977')
  end

  # Checks for number validity as per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # @params number - a string
  def self.messageable_phone_number?(number)
    number = manipulate_phone_number(number)
    non_area_code_segment = number.split('977')[1]
    return non_area_code_segment.present? && non_area_code_segment.length == 10 && non_area_code_segment.starts_with?('984', '985', '986', '980', '981', '974', '975')
  end

end
