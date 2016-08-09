# == Schema Information
#
# Table name: sms_messages
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone                  :string
#  phone_type             :integer          default(0)
#  sms_type               :integer          default(0)
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


  ########################################
  # Notes

  # Sparrow SMS
  # ---------------------------------------
  # As per mail from JanakiTech's CTO Dhruva Adhikari:
  # Message Length block:
  # To simplify,
  #  for normal sms message
  #                Single page = 160 chars
  #                Multi page = 153 * number of pages (viz. 306, 459, ... and so on)
  #
  # for unicode message,
  #                Single page = 70 chars
  #                Multi page = 67 * number of pages (viz. 134, 201, .. and so on)

  # Miracle InfoCom
  # ---------------------------------------
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

  ########################################
  # Relationships

  belongs_to :transaction_message

  ########################################
  # Constants

  MIRACLE_MAX_MESSAGE_BLOCK_LENGTH = 250
  SPARROW_MAX_MESSAGE_BLOCK_LENGTH = 459
  SPARROW_TOKEN = 'Q2qMoJIpim0AgFn34WUz'
  SPARROW_FROM = 'Demo'
  MIRACLE_ACCESS_CODE = 'M210DAF977'
  MIRACLE_USERNAME = 'danpheit'
  MIRACLE_PASSWORD = 'Danfe!23'


  ########################################
  # Enums

  # Expand the enum type to add additional types in the future (For eg: password change PIN sms, etc)
  enum sms_type: [:undefined_sms_type, :transaction_message_sms]
  enum phone_type: [:undefined_phone_type, :ntc, :ncell]

  ########################################
  # Scopes

  scope :by_sms_message_type, -> (type) { where(:sms_type => SmsMessage.sms_types[type]).order(id: :desc) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:updated_at => date_ad.beginning_of_day..date_ad.end_of_day).order(id: :desc)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('updated_at >= ?', date_ad.beginning_of_day).order(id: :desc)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('updated_at <= ?', date_ad.end_of_day).order(id: :desc)
  }

  scope :by_client_id, lambda { |id|
    joins(:transaction_message).where('transaction_messages.client_account_id = ?', id).order(id: :desc)
  }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("sms_messages.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  filterrific(
      default_filter_params: {sorted_by: 'id_desc'},
      available_filters: [
          :sorted_by,
          :by_sms_message_type,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
      ]
  )


  ########################################
  # Instance Methods

  def initialize (args = {})
    super()
    self.phone = args[:phone]
    self.sms_type = args[:sms_type]
    self.transaction_message_id = args[:transaction_message_id]
    self.phone_type = self.class.get_phone_type(self.phone)
    self.credit_used = 0
  end

  ########################################
  # Class Methods

  def self.options_for_sms_message_type_select
    [["Transaction Message", "transaction_message_sms"], ["Undefined", "undefined_sms_type"]]
  end

  def self.options_for_client_select
    ClientAccount.all.order(:name)
  end

  def self.sparrow_test_message
    to = '9779851153385'
    text = 'Hello World from support@dit'
    api_url = "http://api.sparrowsms.com/v2/sms/?token=#{SPARROW_TOKEN}&from=#{SPARROW_FROM}&to=#{to}&text=#{text}"
    credit_before = SmsMessage.sparrow_credit
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    credit_after = SmsMessage.sparrow_credit
    credit_consumed = credit_before.to_i - credit_after.to_i
    p text
    p text.length
    p "Credit consumed: #{credit_consumed}"
    p response
    response_json = JSON.parse(response)
    response_json['response_code']
  end

  # Checks sparrow sms's credit
  def self.sparrow_credit
    token = 'Q2qMoJIpim0AgFn34WUz'
    api_url = "http://api.sparrowsms.com/v2/credit/?token=#{token}"
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    response_json = JSON.parse(response)
    # TODO(sarojk): Look for invalid response with code other than 200, which is valid code.
    # See for more: http://docs.sparrowsms.com/en/latest//outgoing_credits/
    response_json['credits_available']
  end

  def self.sparrow_push_sms
    api_url = "http://api.sparrowsms.com/v2/sms/?token=#{SPARROW_TOKEN}&from=#{SPARROW_FROM}&to=#{@mobile_number}&text=#{@message}"
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    response_json = JSON.parse(response)
    response_json['response_code']
  end

  # Checks miracle's balance
  def self.miracle_credit
    tag = 'BQ'
    result = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + MIRACLE_ACCESS_CODE + '&u=' + MIRACLE_USERNAME + '&p=' + MIRACLE_PASSWORD)).body
    # TODO(sarojk): Check for condition where the server is down or server returns something other than expected result pattern
    # Expected result pattern-ish: "Balance remaining = 93.00"
    result.split('=')[1].strip.to_f
  end

  # The reply_code is a string
  def self.miracle_push_sms
    tag = 'B'
    reply_code = Net::HTTP.get_response(URI.parse('http://api.miracleinfo.com.np/sms/smssend.php?'+ 'tag=' + tag + '&ac=' + MIRACLE_ACCESS_CODE + '&dt=' + @date_time + '&mob=' + @mobile_number + '&msg=' + @message + '&u=' + MIRACLE_USERNAME + '&p=' + MIRACLE_PASSWORD)).body
    reply_code
  end

  def self.miracle_test_message
    self.date_time
    self.mobile_number = '9851153385'
    # self.message = 'Hello, @%40 from support@danpheinfotech.com!'
    self.message = 'o ' * 125
    p self.miracle_push_sms
    p self.miracle_credit
  end

  def self.miracle_send_bill_sms(transaction_message_id)
    self.date_time
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    self.mobile_number = transaction_message.client_account.messageable_phone_number
    sms_message_obj = SmsMessage.new(phone: @mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id)
    #  -split message to sendable blocks(<=255)
    #  -queue all blocks
    #  -in the event one of the blocks fails, unsent! but increase the credit used. remark 'multiple block' message
    #   -else, if none fails, register sent!
    #TODO(sarojk): Consider sane breaking of text . Looks like , and ; are sane break points.
    # http://stackoverflow.com/questions/754407/what-is-the-best-way-to-chop-a-string-into-chunks-of-a-given-length-in-ruby
    # TODO(sarojk): IMPORTANT! Change 250 to 255 after Miracle solves the issue with max message block length.
    sms_message = transaction_message.sms_message
    self.message = sms_message
    sms_message_encoded = @message
    valid_message_blocks = sms_message_encoded.scan(/.{1,250}/)
    sms_failed = false
    transaction_message.sms_queued!
    valid_message_blocks.each do |message|
      self.message = message
      if !Rails.env.production?
        reply_code = Random.rand(3).to_s
      else
        reply_code = self.miracle_push_sms
      end
      if reply_code != '1'
        sms_failed = true
        if transaction_message.sms_message.length >  MIRACLE_MAX_MESSAGE_BLOCK_LENGTH
          sms_message_obj.remarks = 'Not all valid length blocks succesfully sent of this message which is greater than 255 characters.'
        end
        break
      else
        sms_message_obj.credit_used += self.miracle_credit_required(@message)
      end
    end
    if sms_failed
      # If sms has been not been sent before (ie. sms_count == 0), then only set status to sms_unsent.
      # In case, where the sms has been sent before, and a retry is attempted which failed, don't set the sms_unsent
      if transaction_message.sent_sms_count == 0
        transaction_message.sms_unsent!
      else
        # As the transaction message sms_status has been earlier(see above) set to sms_queued, set it back to sms_sent because it is for messages which have sms_sent_count != 0 (ie. the sms_sent successfully in the past.)
        transaction_message.sms_sent!
      end
    else
      transaction_message.increase_sent_sms_count!
      transaction_message.sms_sent!
      sms_message_obj.save!
    end
  end

  def self.sparrow_send_bill_sms(transaction_message_id)
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    @mobile_number = self.strip_non_digit_characters(transaction_message.client_account.mobile_number)
    sms_message_obj = SmsMessage.new(phone: @mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id)
    sms_failed = false
    @message = self.replace_at_sign(transaction_message.sms_message)
    transaction_message.sms_queued!

    if !Rails.env.production?
      reply_code = Random.rand(3) + 200
    else
      reply_code = self.sparrow_push_sms
    end

    if reply_code != 200
      sms_failed = true
    else
      sms_message_obj.credit_used += self.sparrow_credit_required(@message)
    end

    if sms_failed
      # If sms has been not been sent before (ie. sms_count == 0), then only set status to sms_unsent.
      # In case, where the sms has been sent before, and a retry is attempted which failed, don't set the sms_unsent
      if transaction_message.sent_sms_count == 0
        transaction_message.sms_unsent!
      else
        # As the transaction message sms_status has been earlier(see above) set to sms_queued, set it back to sms_sent because it is for messages which have sms_sent_count != 0 (ie. the sms_sent successfully in the past.)
        transaction_message.sms_sent!
      end
    else # sms success
      transaction_message.increase_sent_sms_count!
      transaction_message.sms_sent!
      sms_message_obj.save!
    end
  end

  def self.send_bill_sms(transaction_message_id)
    if self.miracle_credit >= 1.4
      self.miracle_send_bill_sms(transaction_message_id)
    else
      self.sparrow_send_bill_sms(transaction_message_id)
    end
  end

  # Encodes the message specifically encoding the (white)space
  def self.message= (msg)
    @message = self.encode_space(msg)
    @message = self.replace_at_sign(@message)
  end

  def self.encode_space(msg)
    msg.gsub(' ', '%20')
  end

  def self.decode_space(msg)
    msg.gsub('%20', ' ')
  end

  def self.replace_at_sign(msg)
    msg.gsub('@', 'at')
  end

  def self.mobile_number= (number)
    @mobile_number = self.manipulate_phone_number(number)
  end

  # :db used to get the date_time in Miracle recommended syntax of the date.
  def self.date_time
    @date_time = DateTime.now.to_s(:db)
  end

  #
  # Strip any non-digit character
  #
  def self.strip_non_digit_characters(number)
    number ||= ''
    number.to_s.gsub(/\D/, '')
  end

  # If the number doesn't start with 977, prepend 977.
  def self.manipulate_phone_number(number)
    number = self.strip_non_digit_characters(number)
    number = number.prepend('977') unless number.start_with?('977')
    number
  end

  # Checks for number validity as per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # @params number - a string
  def self.messageable_phone_number?(number)
    number = manipulate_phone_number(number)
    non_country_code_segment = number[3..-1]
    return non_country_code_segment.present? && non_country_code_segment.length == 10 && non_country_code_segment.starts_with?('984', '985', '986', '980', '981', '974', '975')
  end

  # Valid message block: 255 characters
  # <= 160 characters = 1 credit
  # > 160 characters && <= 255 characters = +1 credit
  # When a message with 255+ characters is broken to multiple blocks and sent, the credit required is calculated as below.
  def self.miracle_credit_required(message)
    message = self.decode_space(message)
    credit = 0
    message_length = message.length
    while message_length > 0
      if message_length > 160
        credit += 2
        message_length -= MIRACLE_MAX_MESSAGE_BLOCK_LENGTH
      elsif message_length <= 160
        credit += 1
        message_length -= 160
      end
    end
    credit
  end

  def self.sparrow_credit_required(message)
    message ||= ''
    credit_required = 0
    single_page_length = 160
    multi_page_block_length = 153
    message_length = message.length
    if message_length <= single_page_length && message_length > 0
      credit_required = 1
    elsif message_length > single_page_length
      credit_required = (message_length / multi_page_block_length.to_f).ceil
    end
    credit_required
  end

  # As per Miracle Infocom's sendable pattern: 13 digits (prefix: 977) 984,985,986,980,981,974,975
  # ntc_prefixes = ['984', '985', '986']
  # ncell_prefixes = ['980', '981']
  # TODO(sarojk): Find which provider has prefixes 974, 975?
  def self.get_phone_type(phone)
    phone = self.manipulate_phone_number(phone)
    # The phone number after mainpulate_phone_number has country code (977) appended to it.
    non_country_code_segment = phone[3..-1]
    if non_country_code_segment.starts_with?('984', '985', '986')
      return SmsMessage.phone_types[:ntc]
    elsif non_country_code_segment.starts_with?('980', '981')
      return SmsMessage.phone_types[:ncell]
    else
      return SmsMessage.phone_types[:undefined_phone_type]
    end
  end

end
