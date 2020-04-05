require 'rails_helper'

RSpec.describe CustomDateModule, type: :helper do
  let(:dummy_class) { Class.new { extend CustomDateModule } }

  describe "#bs_to_ad" do
    context "when bs date is out of range" do
      it "should return nil" do
        expect(dummy_class.bs_to_ad("1998-02-01")).to eq(nil)
      end
    end

    context "when date bs is invalid" do
      it "should raise error" do
        expect{dummy_class.bs_to_ad("2074-02-33")}.to raise_error('Invalid date!')
      end
    end

    context "when bs date is valid" do
      it "should return ad date" do
        expect(dummy_class.bs_to_ad("2074-04-11")).to eq("2017-07-26".to_date)
      end
    end
  end

  describe "#ad_to_bs" do
    it "should return ad date" do
      expect(dummy_class.send(:ad_to_bs,"2017-07-26")).to eq("2074-04-11")
    end
  end

  describe "#ad_to_bs_string" do
    it "should return ad date" do
      expect(dummy_class.send(:ad_to_bs_string,"2017-07-26")).to eq("2074-04-11")
    end
  end

  describe "#ad_to_bs_string_public" do
    it "should return ad date" do
      expect(dummy_class.ad_to_bs_string_public("2017-07-26")).to eq("2074-04-11")
    end
  end

  describe "#ad_to_bs_hash" do
    it "should return bs date in hash" do
      expect(dummy_class.ad_to_bs_hash("2017-07-26")).to eq({:year => 2074, :month => 4, :day => 11})
    end
  end

  describe "#is_convertible_ad_date?" do
    context "when ad date is in range" do
      it "should return true" do
        expect(dummy_class.is_convertible_ad_date?("2017-07-27".to_date)).to eq(true)
      end
    end
  end

  describe "#is_valid_bs_date?" do
    context "when bs date is not present" do
      it "should return false" do
        expect(dummy_class.is_valid_bs_date?(nil)).not_to be_truthy
      end
    end

    context "when bs date is present" do
      it "should return true" do
        expect(dummy_class.is_valid_bs_date?("2074-04-12")).to be_truthy
      end
    end

    context "when date is invalid" do
      it "should return false" do
        # allow(dummy_class).to receive(:bs_to_ad).and_raise("Invalid date!")
        expect(dummy_class.is_valid_bs_date?("2074-04-33")).not_to be_truthy
      end
    end
  end

  describe "#parsable_date?" do
    context "when date is valid" do
      it "should return true" do
        expect(dummy_class.parsable_date?("2017-08-01")).to eq(true)
      end
    end
    context "when date is invalid" do
      it "should return false" do
        expect(dummy_class.parsable_date?("2017-02-33")).to eq(false)
      end
    end
  end
 end
