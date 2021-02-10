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
class SmsMessage < ApplicationRecord
  # include Auditable
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
  
  # Update(Feb 21, 2018):
  # Ncell numbers should now see the message sender id as `Trishakti` instead of 36001. Non-ncell numbers will see the latter.
  SPARROW_FROM = 'Trishakti'


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
    super
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

  def self.sparrow_push_sms(mobile_number, message)
    mobile_number= self.manipulate_phone_number(mobile_number)
    api_url = "http://api.sparrowsms.com/v2/sms/?token=#{SPARROW_TOKEN}&from=#{SPARROW_FROM}&to=#{mobile_number}&text=#{CGI.escape(message)}"
    response = Net::HTTP.get_response(URI.parse(api_url)).body
    response_json = JSON.parse(response)
    response_json['response_code']
  end

  # force fail is to test the failing nature of the sms sending
  def self.sparrow_send_bill_sms(transaction_message_id, current_user)
    transaction_message = TransactionMessage.find_by(id: transaction_message_id.to_i)
    _mobile_number = transaction_message.client_account.messageable_phone_number
    _branch_id = transaction_message.client_account.branch_id

    sms_message_obj = SmsMessage.new(phone: _mobile_number, sms_type: SmsMessage.sms_types[:transaction_message_sms], transaction_message_id: transaction_message.id, branch_id: _branch_id, current_user_id: current_user.id)
    _full_message = transaction_message.sms_message

    # 459 is size of max block sendable via sparrow sms
    valid_message_blocks = _full_message.scan(/.{1,459}/)
    sms_failed = false
    transaction_message.sms_queued!
    valid_message_blocks.each do |message|
      reply_code = self.sparrow_push_sms(_mobile_number, message)
      if reply_code != 200
        sms_failed = true
      else
        sms_message_obj.credit_used += self.sparrow_credit_required(message)
      end
    end

    if sms_failed
      transaction_message.sms_unsent!
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

  # Used in a cron job by `whenever` gem.
  def self.check_for_sms_credit_shortage
    notification_threshold = 5000
    current_credit = SmsMessage.sparrow_credit.to_i rescue nil
    if current_credit.blank? || current_credit <= notification_threshold
      notification_message = []
      notification_message << "*" * 80
      notification_message << "SMS shortage notification!"
      if current_credit.blank?
        notification_message << "There seems to be a problem fetching sms credit."
        notification_message << "Please try checking manually."
      elsif current_credit <= notification_threshold
        notification_message << "SMS credit: #{current_credit.try(:to_s)}"
      end
      notification_message << "Ran at #{DateTime.now}"
      notification_message << "*" * 80
      concatenated_notification_message = notification_message.join("\n")
      puts concatenated_notification_message
      Rails.logger.info concatenated_notification_message
    else
      # Do nothing. If no output to the system, no cron mail notification is sent out.
    end
  end
end

