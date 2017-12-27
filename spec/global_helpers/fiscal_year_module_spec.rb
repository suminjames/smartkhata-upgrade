require 'rails_helper'

RSpec.describe FiscalYearModule, type: :helper do
  let(:dummy_class) { Class.new { extend FiscalYearModule } }
  include_context 'session_setup'

  describe '#get_previous_fy_code' do
    context "when fy code is not passed" do
      it "returns previous fy code" do
        allow(dummy_class).to receive(:get_fy_code).and_return(7475)
        expect(dummy_class.get_previous_fy_code).to eq(7374)
      end
    end

    context "when fy code is passed" do
      it "returns previous fy code" do
        expect(dummy_class.get_previous_fy_code(7475)).to eq(7374)
      end
    end
  end

  describe '#get_next_fy_code' do
    context "when fy code is not passed" do
      it "returns next fy code" do
        allow(dummy_class).to receive(:get_fy_code).and_return(7475)
        expect(dummy_class.get_next_fy_code).to eq(7576)
      end
    end

    context "when fy code is passed" do
      it "returns next fy code" do
        expect(dummy_class.get_next_fy_code(7879)).to eq(7980)
      end
    end
  end

  describe "#get_fy_code" do
    it "should return fy_code" do
      expect(dummy_class.get_fy_code(Date.parse("2017-08-01"))).to eq(7475)
    end
  end

  describe "#fiscal_year_breakpoint_single" do
    context "when date is present" do
      it "should return fy_code breakpoint" do
        expect(dummy_class.fiscal_year_breakpoint_single(date: "2017-08-01".to_date)).to eq([7475, Date.parse('2017-7-16'), Date.parse('2018-7-15')])
      end
    end
    context "when fy_code is present" do
      it "should return fy_code breakpoint" do
        expect(dummy_class.fiscal_year_breakpoint_single(fy_code: 7475)).to eq([7475, Date.parse('2017-7-16'), Date.parse('2018-7-15')])
      end
    end
  end

  describe "#fiscal_year_first_day" do
    # UserSession.selected_fy_code = 7374
    context "when fy_code is present" do
      it "should return first day of fiscal year" do
        expect(dummy_class.fiscal_year_first_day(UserSession.selected_fy_code)).to eq("2016-7-16".to_date)
      end
    end
    context "when fy_code is nil" do
      it "should return todays date" do
        expect(dummy_class.fiscal_year_first_day(nil)).to eq(Date.today)
      end
    end
  end

  describe "#fiscal_year_last_day" do
    # UserSession.selected_fy_code = 7374
    context "when fy_code is present" do
      it "should return last day of fiscal year" do
        expect(dummy_class.fiscal_year_last_day(UserSession.selected_fy_code)).to eq("2017-7-15".to_date)
      end
    end
    context "when fy_code is nil" do
      it "should return todays date" do
        expect(dummy_class.fiscal_year_last_day(nil)).to eq(Date.today)
      end
    end
  end

  describe "#date_valid_for_fy_code" do
    context "when date is within range" do
      it "should return true" do
        expect(dummy_class.date_valid_for_fy_code(Date.parse("2017-08-02"),7475)).to be_truthy
      end
    end
    context "when date out of range" do
      it "should return false" do
        expect(dummy_class.date_valid_for_fy_code(Date.parse("2017-07-02"),7475)).not_to be_truthy
      end
    end
  end

  describe "#get_fy_code_from_fiscal_year" do
    it "should return fy_code" do
      expect(dummy_class.get_fy_code_from_fiscal_year("2074/2075")).to eq(7475)
    end
  end

  describe "#get_fiscal_year_from_fycode" do
    it "should return fiscal year" do
      expect(dummy_class.get_fiscal_year_from_fycode(7374)).to eq("2073/2074")
    end
  end

  describe "#get_full_fy_codes_after_date" do
    context "when exclusive" do
      it "should return fy_codes excluding fy_code for date" do
        expect(dummy_class.get_full_fy_codes_after_date("2017-08-02".to_date,true)).to eq([7576, 7677, 7778, 7879, 7980])
      end
    end
    context "when not exclusive" do
      it "should return fy_codes including fy_code for date" do
        expect(dummy_class.get_full_fy_codes_after_date("2017-08-02".to_date,false)).to eq([7475, 7576, 7677, 7778, 7879, 7980])
      end
    end
  end
end
