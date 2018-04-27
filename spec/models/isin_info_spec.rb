require 'rails_helper'

RSpec.describe IsinInfo, type: :model do
	subject{create(:isin_info)}
  	include_context 'session_setup'

  	describe "validations" do
  		it { should validate_presence_of(:company)}
  		it { should validate_presence_of(:isin)}	
  		it { should validate_uniqueness_of(:isin).case_insensitive }
  	end

  	describe ".name_and_code" do
  		it "should return isin and company" do
  			expect(subject.name_and_code).to eq("DAN (Test Pvt. Ltd.)")
  		end
  	end

    describe "#options_for_isin_info_select" do
      context "when filterrific params present" do
        it "should return isin info" do
          expect(subject.class.options_for_isin_info_select(:by_isin_info_id => subject.id)).to eq([subject])
        end
      end

      context "when filterrific params not present" do
        it "should return empty array" do
          expect(subject.class.options_for_isin_info_select(:by_isin_info_id => nil)).to eq([])
        end
      end
    end

  	describe "#options_for_sector_select" do
  		context "when isin info sector isnot present" do
  			it "should return empty array" do
  				subject.sector = nil
  				subject.save
  				expect(subject.class.options_for_sector_select).to eq([])
  			end
  		end 

  		context "when isin info sector is present" do
  			it "should return array" do
  				expect(subject.class.options_for_sector_select).to eq([["technology", "technology"]])
  			end
  		end 
  	end

  	describe "#find_similar_to_term" do
  		context "when search term is not present" do
  			it do
  				expect(subject.class.find_similar_to_term(nil)).to eq([{:text=>"DAN (Test Pvt. Ltd.)", :id=>"#{subject.id}"}])
  			end
  		end

  		context "when search term is present" do
  			context "and company for isin info present" do
  				it "should return similar term" do
  					expect(subject.class.find_similar_to_term("Te")).to eq([:text=> "DAN (Test Pvt. Ltd.)", :id => "#{subject.id}"])
  				end
  			end
  		end

  		context "when search term is present" do
  			context "and company for isin info present" do
  				it "should return similar term" do
  					expect(subject.class.find_similar_to_term("De")).to eq([])
  				end
  			end
  		end
  	end

  	describe "#find_or_create_new_by_symbol" do
  		context "when company_info is not present" do
  			it "should create new" do
	  			expect{subject.class.find_or_create_new_by_symbol("D")}.to change {subject.class.count}.from(1).to(2)
  			end
  		end

  		context "when company_info is present" do
  			it "should return company info" do
	  			expect(subject.class.find_or_create_new_by_symbol("DAN")).to eq(subject)
  			end
  		end
    end

		describe "#options_for_isin_select" do
			it "returns options for isin select" do
				subject.isin = 'DAN'
				isin_info1 = create(:isin_info, isin: 'ABC')
				isin_info2 = create(:isin_info, isin: 'XYZ')
				expect(subject.class.options_for_isin_select).to eq(['ABC', 'DAN', 'XYZ'])
			end
		end

end
