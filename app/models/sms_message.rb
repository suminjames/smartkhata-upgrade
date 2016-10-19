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

  # Push SMS Response Code
  # Valid Response. Status Code: 200
  #  Response Message.
  #   {
  #       "count": number_of_sms_sent,
  #       "response_code": 200,
  #       "response": "number_of_sms_sent mesages has been queued for delivery"
  #   }
  # Invalid Response. Status Code: 403
  #  Error Messages:
  #   {"response_code":1000,"response":"A required field is missing"}
  #   {"response_code":1001,"response":"Invalid IP Address"}
  #   {"response_code":1002,"response":"Invalid Token"}
  #   {"response_code":1003,"response":"Account Inactive"}
  #   {"response_code":1004,"response":"Account Inactive"}
  #   {"response_code":1005,"response":"Account has been expired"}
  #   {"response_code":1006,"response":"Account has been expired"}
  #   {"response_code":1007,"response":"Invalid Receiver"}
  #   {"response_code":1008,"response":"Invalid Sender"}
  #   {"response_code":1010,"response":"Text cannot be empty"}
  #   {"response_code":1011,"response":"No valid receiver"}
  #   {"response_code":1012,"response":"No Credits Available"}
  #   {"response_code":1013,"response":"Insufficient Credits"}
  #  See for more: http://docs.sparrowsms.com/

  ########################################
  # Relationships

  belongs_to :transaction_message

  ########################################
  # Constants

  SPARROW_MAX_MESSAGE_BLOCK_LENGTH = 459
  SPARROW_TOKEN = 'Q2qMoJIpim0AgFn34WUz'
  SPARROW_FROM = 'Demo'


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

  def self.sparrow_test_message
    self.mobile_number = '9851153385'
    self.message = 'Saroj bought EBL,100@2900;On 1/23 Bill No7273-79 .Pay Rs 292678.5.BNo 48. sarojk@dandpheit.com'
    api_url = "http://api.sparrowsms.com/v2/sms/?token=#{SPARROW_TOKEN}&from=#{SPARROW_FROM}&to=#{@mobile_number}&text=#{CGI.escape(@message)}"
    p api_url
    credit_before = SmsMessage.sparrow_credit
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    credit_after = SmsMessage.sparrow_credit
    credit_consumed = credit_before.to_i - credit_after.to_i
    p "Message: #{@message}"
    p "Message Length: #{@message.length}"
    p "Credit consumed: #{credit_consumed}"
    p "Response: #{response}"
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
    api_url = "http://api.sparrowsms.com/v2/sms/?token=#{SPARROW_TOKEN}&from=#{SPARROW_FROM}&to=#{@mobile_number}&text=#{CGI.escape(@message)}"
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    response_json = JSON.parse(response)
    response_json['response_code']
  end

  def self.sparrow_send_bill_sms(transaction_message_id)
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    self.mobile_number = transaction_message.client_account.messageable_phone_number
    sms_message_obj = SmsMessage.new(phone: @mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id)
    self.message = transaction_message.sms_message


    # 459 is size of max block sendable via sparrow sms
    valid_message_blocks = @message.scan(/.{1,459}/)
    sms_failed = false
    transaction_message.sms_queued!

    valid_message_blocks.each do |message|
      self.message = message
      if !Rails.env.production?
        reply_code = Random.rand(2) + 200
      else
        reply_code = self.sparrow_push_sms
      end

      if reply_code != 200
        sms_failed = true
        if transaction_message.sms_message.length >  SPARROW_MAX_MESSAGE_BLOCK_LENGTH
          sms_message_obj.remarks = "Not all valid length blocks succesfully sent of this message which is greater than  #{SPARROW_MAX_MESSAGE_BLOCK_LENGTH} characters."
        end
        break
      else
        sms_message_obj.credit_used += self.sparrow_credit_required(@message)
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
    else # sms success
      transaction_message.increase_sent_sms_count!
      transaction_message.sms_sent!
      sms_message_obj.save!
    end
  end

  def self.message= (msg)
    @message = msg
  end

  def self.replace_at_sign(msg)
    msg.gsub('@', 'at')
  end

  def self.mobile_number= (number)
    @mobile_number = self.manipulate_phone_number(number)
  end

  #
  # Strip any non-digit character
  #
  def self.strip_non_digit_characters(number)
    number ||= ''
    number.to_s.gsub(/\D/, '')
  end

  #
  # Checks for general phone number validity.
  # Sparrow's API accepts numbers from NTC(GSM, CDMA), Ncell, UTL, Smart Tel.
  # No specific guideline as to which prefixes are valid numbers is provided.
  # @params number - a string
  #
  def self.messageable_phone_number?(number)
    number = self.manipulate_phone_number(number)
    return number.length == 13
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

  #
  # This phone_type enum exists so that DIT's accounting for messages can be done separately for separate carriers (in the future).
  # TODO(sarojk): Populate the prefixes
  #
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

  #
  # Strip number of any non digit characters
  # If the number doesn't start with 977, prepend 977.
  #
  def self.manipulate_phone_number(number)
    number = self.strip_non_digit_characters(number)
    number = number.prepend('977') unless number.start_with?('977')
    number
  end

end

