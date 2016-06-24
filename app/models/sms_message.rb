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

  def self.send_hello_world
    self.date_time = DateTime.now.to_s(:db)
    self.mobile_number = '9779851182852'
    self.message = 'Hello World, from DIT'
  end

  def self.push_sms
    # result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + @tag + '&ac=' + @access_code + '&dt=' + @date_time + '&mob=' + @mobile_number + '&msg=' + @message + '&u=' + @username + '&p=' + @password)).body
    # p result
  end

  def self.send_bill_sms(transaction_message_id )
    self.date_time
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    self.message = transaction_message.sms_message
    self.date_time
    self.mobile_number = '(98511)53-3 85'
    self.push_sms
  end

  # Encodes the message specifically encoding the (white)space
  def self.message= (msg)
    @message = msg.gsub!(' ', '%20')
  end

  # TODO(sarojk): Check validity of number (as in it is a valid cell phone number)
  # @params number - a string
  # 13 digits (prefix: 977) 984,985,986,980,981,974,975
  def self.mobile_number= (number)
    # Strip any non-digit character
    @mobile_number = number.to_s.gsub(/\D/, '')
    # If the number doesn't start with 977, prepend 977.
    @mobile_number = @mobile_number.prepend('977') unless @mobile_number.start_with?('977')
  end

  def self.date_time
    @date_time = DateTime.now.to_s(:db)
  end
end
