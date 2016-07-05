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
  extend CustomDateModule

  include ::Models::UpdaterWithBranchFycode

  belongs_to :transaction_message

  # Expand the enum type to add additional types in the future (For eg: password change PIN sms, etc)
  enum sms_type: [:undefined_sms_type, :transaction_message_sms]
  enum phone_type: [:undefined_phone_type, :ntc, :ncell]


  filterrific(
      # default_filter_params: {sorted_by: 'name_desc'},
      available_filters: [
          :sorted_by,
          :by_sms_message_type,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
      ]
  )

  scope :by_sms_message_type, -> (type) { where(:sms_type=> SmsMessage.sms_types[type]) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:created_at => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('created_at >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('created_at <= ?', date_ad.end_of_day)
  }

  scope :by_client_id, lambda { |id|
    joins(:transaction_message).where('transaction_messages.client_account_id = ?', id)
  }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    # case sort_option.to_s
    #   # when /^name/
    #   #   order("LOWER(sms_messages.name) #{ direction }")
    #   # when /^amount/
    #   #   order("sms_messages.amount #{ direction }")
    #   # when /^type/
    #   #   order("sms_messages.sms_messages#{ direction }")
    #   # when /^date/
    #   #   order("sms_messagesms_messages.date_bs #{ direction }")
    #   # else
    #   #   raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    # end
  }

  def self.options_for_sms_message_type_select
    [["Transaction Message", "transaction_message_sms"], ["Undefined", "undefined_sms_type"]]
  end

  def self.options_for_client_select
    ClientAccount.all.order(:name)
  end

  # TODO(sarojk): IMPORTANT! Valid message block's length should have been 255, but Miracle has issues and can only send 250 lenth message block currently. Check and change later.
  MAX_MESSAGE_BLOCK_LENGTH = 250

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

  def initialize (args = {})
    super()
    self.phone = args[:phone]
    self.sms_type = args[:sms_type]
    self.transaction_message_id = args[:transaction_message_id]
    self.phone_type = self.class.get_phone_type(self.phone)
    self.credit_used = 0
  end


  def self.check_balance
    tag = 'BQ'
    result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + @access_code + '&u=' + @username + '&p=' + @password)).body
    # TODO(sarojk): Check for condition where the server is down or server returns something other than expected result pattern
    # Expected result pattern-ish: "Balance remaining = 93.00"
    result.split('=')[1].strip.to_f
  end

  # The reply_code is a string
  def self.push_sms
    tag = 'B'
    reply_code = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + @access_code + '&dt=' + @date_time + '&mob=' + @mobile_number + '&msg=' + @message + '&u=' + @username + '&p=' + @password)).body
  end

  def self.send_hello_world(current_tenant_id)
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    self.date_time
    self.mobile_number = '9851153385'
    self.message = 'Hello, from DIT!'
    p self.push_sms
    p self.check_balance
    Apartment::Tenant.switch!('public')
  end

  def self.send_bill_sms(transaction_message_id, current_tenant_id )
    @current_tenant = Tenant.find_by_id(current_tenant_id)
    Apartment::Tenant.switch!(@current_tenant.name)
    self.date_time
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    self.mobile_number = transaction_message.client_account.messageable_phone_number
    self.date_time
    sms_message_obj = SmsMessage.new(phone: @mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id)
    #  -split message to sendable blocks(<=255)
    #  -queue all blocks
    #  -in the event one of the blocks fails, unsent! but increase the credit used. remark 'multiple block' message
    #   -else, if none fails, register sent!
    #TODO(sarojk): Consider sane breaking of text . Looks like , and ; are sane break points.
    # http://stackoverflow.com/questions/754407/what-is-the-best-way-to-chop-a-string-into-chunks-of-a-given-length-in-ruby
    # TODO(sarojk): IMPORTANT! Change 250 to 255 after Miracle solves the issue with max message block length.
    valid_message_blocks = transaction_message.sms_message.scan(/.{1,250}/)
    sms_failed = false
    transaction_message.sms_queued!
    valid_message_blocks.each do |message|
      self.message = message
      # reply_code = self.push_sms
      reply_code = '1'
      if reply_code != '1'
        sms_failed = true
        if transaction_message.sms_message.length >  MAX_MESSAGE_BLOCK_LENGTH
          sms_message_obj.remarks = 'Not all valid length blocks succesfully sent of this message which is greater than 255 characters.'
        end
        break
      else
        sms_message_obj.credit_used += self.credit_required(@message)
      end
    end
    if sms_failed
      transaction_message.sms_unsent!
    else
      transaction_message.increase_sent_sms_count!
      transaction_message.sms_sent!
      sms_message_obj.save
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

  # :db used to get the date_time in Miracle recommended syntax of the date.
  def self.date_time
    @date_time = DateTime.now.to_s(:db)
  end

  # Strip any non-digit character
  # If the number doesn't start with 977, prepend 977.
  def self.manipulate_phone_number(number)
    number = number.to_s.gsub(/\D/, '')
    number = number.prepend('977') unless number.start_with?('977')
    number
  end

  # Checks for number validity as per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # @params number - a string
  def self.messageable_phone_number?(number)
    number = manipulate_phone_number(number)
    non_area_code_segment = number.split('977')[1]
    return non_area_code_segment.present? && non_area_code_segment.length == 10 && non_area_code_segment.starts_with?('984', '985', '986', '980', '981', '974', '975')
  end

  # Valid message block: 255 characters
  # <= 160 characters = 1 credit
  # > 160 characters && <= 255 characters = +1 credit
  # When a message with 255+ characters is broken to multiple blocks and sent, the credit required is calculated as below.
  def self.credit_required(message)
    credit = 0
    message_length = message.length
    while message_length > 0
      if message_length > 160
        credit += 2
        message_length -= MAX_MESSAGE_BLOCK_LENGTH
      elsif message_length <= 160
        credit += 1
        message_length -= 160
      end
    end
    credit
  end

  # As per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # ntc_prefixes = ['984', '985', '986']
  # ncell_prefixes = ['980', '981']
  # TODO(sarojk): Find which provider has prefixes 974, 975?
  def self.get_phone_type(phone)
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

end
