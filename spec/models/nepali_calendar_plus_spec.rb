require 'rails_helper'

RSpec.describe NepaliCalendarPlus::CalendarPlus, type: :model do
	subject{build(:calendar_plus)}
  	include_context 'session_setup'

  	describe "#today" do
  		it "should return date in bs" do
  			allow(Date).to receive(:today).and_return('2017-06-12'.to_date)
  			expect(NepaliCalendarPlus::CalendarPlus.today).to eq({:year=>2074, :month=>2, :day=>29})
  		end
  	end

  	# describe ".ad_to_bs_hash" do

  	# end

  	describe ".ad_to_bs_string" do
  		it "should return date in bs" do
  			expect(subject.ad_to_bs_string("2017","06","12")).to eq("2074-2-29")
  		end
  	end

end
