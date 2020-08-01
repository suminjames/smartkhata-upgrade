# == Schema Information
#
# Table name: interest_rates
#
#  id            :integer          not null, primary key
#  start_date    :date
#  end_date      :date
#  interest_type :integer
#  rate          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe InterestRate, type: :model do
  subject { create(:interest_rate) }

  describe "validations" do
    it { should validate_inclusion_of(:rate).in_range(1..100).with_message("Rate should lie between 1 and 100.") }
    it { should define_enum_for(:interest_type) }
  end

  describe "validate_date_range" do
    context "when start_date is equal to or greater than end_date" do
      let(:start_date) { Date.today - 5.days }
      let(:end_date) { Date.today - 7.days }
      let(:invalid_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date) }
      it "raises the validation error" do
        invalid_interest_rate.valid?
        expect(invalid_interest_rate.errors[:start_date]).to include("Start date should be before the end date")
      end
    end

    context "when start_date is less than end_date" do
      let(:start_date) { Date.today - 7.days }
      let(:end_date) { Date.today - 4.days }
      let(:valid_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date) }
      it "passes the validation" do
        valid_interest_rate.valid?
        expect(valid_interest_rate.errors[:start_date]).to_not include("Start date should be before the end date")
      end
    end
  end

  describe "validate_interest_rate_overlap" do
    context "when the new date range lies between previous record date range" do
      let(:start_date) { Date.today - 20.days }
      let(:end_date) { Date.today - 10.days }
      let(:rate) { 20 }

      context "and the new interest_type matches to previous record interest_type" do
        let(:interest_type) { "payable" }
        let(:overlapped_record) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type, rate: rate) }

        it "raises the validation error" do
          expect(subject.start_date..subject.end_date).to include(overlapped_record.start_date, overlapped_record.end_date)
          expect(subject.interest_type).to eq(overlapped_record.interest_type)
          overlapped_record.valid?
          expect(overlapped_record.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the new interest_type doesn't match to previous record interest_type" do
        let(:interest_type) { "receivable" }
        let(:another_overlapped_record) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type, rate: rate) }

        it "passes the validation" do
          another_overlapped_record.valid?
          expect(another_overlapped_record.errors[:start_date]).to_not include(["An interest rate record in the given date range already exists!"])
        end
      end
    end

    context "when the new date range doesn't lie between any previous record date range" do
      let(:start_date) { Date.today - 120.days }
      let(:end_date) { Date.today - 100.days }
      let(:another_interest_record) { build(:interest_rate, start_date: start_date, end_date: end_date) }

      it "passes the validation" do
        another_interest_record.valid?
        expect(another_interest_record.errors[:start_date]).to_not include(["An interest rate record in the given date range already exists!"])
      end
    end
  end
end
