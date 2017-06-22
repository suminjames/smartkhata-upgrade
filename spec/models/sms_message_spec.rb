require 'rails_helper'

RSpec.describe SmsMessage, type: :model do
	subject{build(:sms_message)}
  	include_context 'session_setup'

  	describe "#options_for_sms_message_type_select" do
  		it "returns options for sms message type" do
  			expect(SmsMessage.options_for_sms_message_type_select).to eq([["Transaction Message", "transaction_message_sms"], ["Undefined", "undefined_sms_type"]])
  		end
  	end

  	describe "#sparrow_test_message" do
  		it ""
  	end

  	describe "#sparrow_credit" do
  		it ""
  	end

  	describe "#sparrow_push_sms" do
  		it "sends sms using sparrow" do
				VCR.use_cassette('sparrow_sms') do
          message = "Saroj bought EBL,100@2900;On 1/23 Bill No7273-79 .Pay Rs 292678.5.BNo 48. sarojk@dandpheit.com"
					mobile_number = '9851182852'
          expect(SmsMessage.sparrow_push_sms(mobile_number, message)).to eq(200)
				end
      end
  	end

  	describe "#sparrow_send_bill_sms" do
      context "successfully sending single sms" do
				before do
					@transaction_message = create(:transaction_message)
					VCR.use_cassette('sparrow_sms') do
						SmsMessage.sparrow_send_bill_sms(@transaction_message.id)
					end
				end

				it "sends sms using sparrow" do
					expect(@transaction_message.reload.sms_sent?).to be_truthy
					expect(@transaction_message.reload.sent_sms_count).to eq 1
				end

				it "stores sms credit" do
					expect(SmsMessage.last.credit_used).to eq(1)
				end
      end

      context "when sending multiple sms" do
        before do
					allow(SmsMessage).to receive(:sparrow_push_sms).and_return(200)
        end
        context "and message length is greater than 459" do
					it "updates sms credit" do
						@transaction_message = create(:transaction_message, sms_message: "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789")
						SmsMessage.sparrow_send_bill_sms(@transaction_message.id)
						expect(@transaction_message.reload.sms_sent?).to be_truthy
						expect(@transaction_message.reload.sent_sms_count).to eq 1
						expect(SmsMessage.last.credit_used).to eq(4)
          end
        end
      end

      context "error on sms sending" do
				before do
					@transaction_message = create(:transaction_message)
          allow(SmsMessage).to receive(:sparrow_push_sms).and_return(300)
        end

        it "	"
      end

  	end

  	describe "#message=" do
  		it "returns message" do
  			expect(SmsMessage.message=("hello")).to eq("hello")
  		end
  	end

  	describe "#replace_at_sign" do
  		it "replaces at sign" do
  			expect(SmsMessage.replace_at_sign("@ 9'o clock")).to eq("at 9'o clock")
  		end
  	end
  	
  	describe "#mobile_number=" do
  		it "returns mobile number" do
  			expect(SmsMessage.mobile_number='9841909809').to eq('9841909809')
  		end
  	end

  	describe "#strip_non_digit_characters" do
  		it "removes any non digit character" do
  			expect(SmsMessage.strip_non_digit_characters('9841654387s')).to eq('9841654387')
  		end
	end

	describe "#messageable_phone_number?" do
		it "checks general phone number" do
			expect(SmsMessage.messageable_phone_number?('9841909809')).to be_truthy
		end
	end

	describe "#sparrow_credit_required" do
		context "when message length is less than single page length" do
			it "returns credit required as 1" do
				expect(SmsMessage.sparrow_credit_required('hello')).to eq(1)
			end
		end

		context "when message length is greater than single page length" do
			it "returns credit required" do
        # 161 = 153 + 8
				expect(SmsMessage.sparrow_credit_required("a"*161)).to eq(2)
        # 160+153 = 153 + 153 + 7
				expect(SmsMessage.sparrow_credit_required("a"*313)).to eq(3)
			end
		end
	end

	describe "#get_phone_type" do
    context "when non country code starts with 984,985,986" do
      it "gets phone type as ntc" do
       expect(SmsMessage.get_phone_type('9779849876876')).to eq(1)
      end
    end

    context "when non country code starts with 980,981" do
      it "gets phone type as ncell" do
       expect(SmsMessage.get_phone_type('9803876876')).to eq(2)
      end
    end

    context "when non country code starts with other" do
      it "gets phone type as undefined phone type" do
       expect(SmsMessage.get_phone_type('55876876')).to eq(0)
      end
    end
	end

	describe "#manipulate_phone_number" do
		context "when number not start with 977" do
			it "adds 977 to phone number" do
				expect(SmsMessage.manipulate_phone_number('9898764532')).to eq('9779898764532')
			end

			context "and non digit character is present" do
				it "removes non digit character and adds 977 to number" do
					expect(SmsMessage.manipulate_phone_number('ab9898764532')).to eq('9779898764532')
				end

			end
		end
		

	end

end