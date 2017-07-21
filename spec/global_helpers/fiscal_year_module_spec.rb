require 'rails_helper'

RSpec.describe FiscalYearModule, type: :helper do
  let(:dummy_class) { Class.new { extend FiscalYearModule } }

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
end
