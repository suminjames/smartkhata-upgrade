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

  	describe ".ad_to_bs_hash" do
  		context "when invalid ad date" do
  			it "should return error" do
  				expect{subject.ad_to_bs_hash("2017","02","30")}.to raise_error("Invalid date!")
  			end
  		end

  		it "should return nill if date is out of range" do
  			expect(subject.ad_to_bs_hash("1943","01","01")).to be_nil
  		end

  		it "should return correct date" do
  			expect(subject.ad_to_bs_hash("2017","06","12")).to eq({:year=>2074, :month=>2, :day=>29})
  		end
  	end

  	describe ".ad_to_bs_string" do
  		it "should return date in bs" do
  			expect(subject.ad_to_bs_string("2017","06","12")).to eq("2074-2-29")

  			expect(subject.ad_to_bs_string("1943","01","01")).to be_nil
  		end
  	end

  	describe ".get_bs_date" do
  		context "when bs date is second year from start ref" do
  			it "should get bs date" do
  				expect(subject.get_bs_date(366,"2000/09/17")).to eq({:year=>2001, :month=>9, :day=>18})
  			end
  		end

  		context "when date is 2017/06/12" do
  			it "should get bs date" do
  				expect(subject.get_bs_date(26826,"2000/09/17")).to eq({:year=>2074, :month=>2, :day=>29})
  			end
  		end
  		
  	end

    describe ".bs_to_ad" do
      context "when date is invalid" do
        it "should return error" do
          expect{subject.bs_to_ad("2074","02","34")}.to raise_error("Invalid date!")
        end
      end

      context "when date is out of range" do
        it "should return nil" do
          expect(subject.bs_to_ad("1998","01","01")).to be_nil
        end
        it "should return nil" do
          expect(subject.bs_to_ad(1998,01,01)).to be_nil
        end
      end

      it "should return correct date" do
        expect(subject.bs_to_ad(2074,02,30)).to eq(Date.parse("Tue, 13 Jun 2017"))
      end
    end

    describe ".get_ad_date" do
      it "should get ad date" do
        expect(subject.get_ad_date("2002","01","01","2001/01/01")).to eq(Date.parse('Thu, 13 Apr 1944'))
      end
    end

    describe ".total_days" do
      it "should return total days" do
        expect(subject.total_days("2017/01/01".to_date,"2016/01/01".to_date)).to eq(366)
      end
    end

    describe ".ad_date_in_range?" do
      it "should be true" do
        expect(subject.ad_date_in_range?('2017/01/01','2016/01/01')).to be_truthy
      end
    end

    describe ".bs_date_in_range" do
      context "when date is lesser than reference date" do
        it "should return false" do
          date = {:year=> 1997, :month => 2, :day => 30}
            reference_date = "2000/01/01".to_date
            expect(subject.bs_date_in_range?(date,reference_date)).not_to be_truthy
        end
      end

      context "when date is greater than reference date" do
        context "and date year is greater than ref year" do
          it "should return true" do
            date = {:year=> 2074, :month => 2, :day => 30}
            reference_date = "2000/01/01".to_date
            expect(subject.bs_date_in_range?(date,reference_date)).to be_truthy
          end
        end

        context "and date month is greater than ref date" do
          it "should return true" do
            date = {:year=> 2000, :month => 2, :day => 30}
            reference_date = "2000/01/01".to_date
            expect(subject.bs_date_in_range?(date,reference_date)).to be_truthy
          end
        end

         context "and date day is greater than ref day" do
          it "should return true" do
            date = {:year=> 2000, :month => 2, :day => 30}
            reference_date = "2000/01/01".to_date
            expect(subject.bs_date_in_range?(date,reference_date)).to be_truthy
          end
        end
        
      end

    end

    describe ".valid_bs_date" do
      it "should return true" do
        expect(subject.valid_bs_date?(2000,02,01)).to be_truthy
      end

      it "should return false" do
       expect(subject.valid_bs_date?(1998,02,01)).not_to be_truthy
      end
    end

    describe ".valid_ad_date" do
      it "should return true" do
        expect(subject.valid_ad_date?(2016,02,01)).to be_truthy
      end
    end

end
