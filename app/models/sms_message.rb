# == Schema Information
#
# Table name: sms_messages
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone                  :string
#  phone_type             :integer          default("0")
#  sms_type               :integer          default("0")
#  credit_used            :integer
#  remarks                :integer
#  transaction_message_id :integer
#  creator_id             :integer
#  updater_id             :integer
#  fy_code                :integer
#  branch_id              :integer
#

require 'net/http'
class SmsMessage < ActiveRecord::Base

  include ::Models::UpdaterWithBranchFycode

  belongs_to :transaction_message

  # Expand the enum type to add additional types in the future (For eg: password change PIN sms, etc)
  enum sms_type: [:undefined_sms_type, :transaction_sms]
  enum phone_type: [:undefined_phone_type, :ntc, :ncell]

  @access_code = 'M210DAF977'
  @username = 'danpheit'
  @password = 'Danfe!23'

  # Reply code:
  #  0 = Error
  #  1 = Successfully record accept to send.
  #  2 = Invalid tag.
  #  3 = Missing Parameter.
  #  4 = Null parameter.
  #  5 = Invalid access code.
  #  6 = Invalid Username / Password.
  #  7 = Message length exceed more than 255 characters.
  #  8 = Invalid values in parameters like date incorrect format, mobile != 13 digits
  #  9 = Balance not enough.

  def initialize (phone, sms_type, remarks, transaction_message_id)
    @phone = phone
    @sms_type = sms_type
    @credit_used = self.credit_used
    @remarks = remarks || ''
    @transaction_message_id = transaction_message_id
    @phone_type = self.phone_type(@phone)
  end

  # As per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # ntc_prefixes = ['984', '985', '986']
  # ncell_prefixes = ['980', '981']
  # TODO(sarojk): Find which provider has prefixes 974, 975?
  def self.phone_type(phone)
    phone = self.manipulate_phone_number(phone)
    non_area_code_segment = phone.split('977')[1]
    if non_area_code_segment.starts_with?('984', '985', '986')
      return SmsMessage.phone_types[:ntc]
    elsif non_area_code_segment.starts_with?('980', '981')
      return SmsMessage.phone_types[:ncell]
    else
      return SmsMessage.phone_types[:undefined_phone_type]
    end
  end

  def self.check_balance
    tag = 'BQ'
    result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + @access_code + '&u=' + @username + '&p=' + @password)).body
    # TODO(sarojk): Check for condition where the server is down or server returns something other than expected result pattern
    # Expected result pattern-ish: "Balance remaining = 93.00"
    result.split('=')[1].strip.to_f
  end

  def self.send_hello_world(current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    @date_time = DateTime.now.to_s(:db)
    self.mobile_number = '9845817957'
    @message = 'a' * 251
    p @message
    p @message.length
    p self.push_sms
    p self.check_balance
    Apartment::Tenant.switch!('public')
  end

  def self.send_message_gt_255
    @message = "Yesterday all my troubles seemed so far away. Now it looks as though they're here to stay. Oh, I believe in yesterday. Suddenly I'm not half the man I used to be. There's a shadow hanging over me. Oh, yesterday came suddenly. Why she had to go, I don't know, she wouldn't say. I said something wrong, now I long for yesterday."
  end

  # The reply_code is a string
  def self.push_sms
    tag = 'B'
    reply_code = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + @access_code + '&dt=' + @date_time + '&mob=' + @mobile_number + '&msg=' + @message + '&u=' + @username + '&p=' + @password)).body
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

  def self.credit_used
    credit = 0
    case @message.length
      when 0
        credit = 0
      when 1..160
        credit = 1
      when 160..255
        credit = 2
      else
        credit = 0
    end
    credit
  end
end
