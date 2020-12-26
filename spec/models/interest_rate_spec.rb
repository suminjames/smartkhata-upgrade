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
  subject { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type, rate: rate) }
  let(:start_date) { Date.today - 40.days }
  let(:end_date) { Date.today - 10.days }
  let(:rate) { 10 }
  let(:interest_type) { "payable" }

  describe "validations" do
    it { should validate_inclusion_of(:rate).in_range(1..100).with_message("Rate should lie between 1 and 100.") }
    it { should define_enum_for(:interest_type) }
  end

  describe "date validations" do
    context "when both of the start_date and end_date are present" do
      it "passes the validation" do
        expect{ subject }.not_to raise_error
      end
    end

    context "when start_date is nil" do
      let(:start_date) { nil }
      it "fails the validation" do
        subject.valid?
        expect(subject.errors[:start_date]).to eq(["can't be blank"])
      end
    end

    context "when the end_date is nil" do
      let(:end_date) { nil }
      it "fails the validation" do
        subject.valid?
        expect(subject.errors[:end_date]).to eq(["can't be blank"])
      end
    end
  end

  describe "validate_date_range" do

    context "when start_date is greater than the end_date" do
      let(:start_date){ end_date + 1.day }
      let(:end_date) { Date.today }
      it "raises the validation error" do
        subject.start_date = Date.today - 15.days
        subject.end_date = Date.today - 20.days
        subject.valid?
        expect(subject.errors[:start_date]).to eq(["Start date should be before the end date"])
      end
    end

    context "when start_date is equal to end_date" do
      let(:start_date){ end_date }
      let(:end_date) { Date.today }
      it "raises the validation error" do
        subject.valid?
        expect(subject.errors[:start_date]).to eq(["Start date should be before the end date"])
      end
    end

    context "when start_date is less than the end date" do
      it "passes the validation" do
        subject.valid?
        expect(subject.errors[:start_date]).to_not eq(["Start date should be before the end date"])
      end
    end
  end

  describe "validate_interest_rate_overlap" do

    context "when the interest_type is different with previous record interest_type" do
      let(:another_interest_rate) { create(:interest_rate, start_date: start_date, end_date: end_date, interest_type: another_interest_type, rate: rate) }
      let(:another_interest_type) { "receivable" }
      
      before { another_interest_rate }
      
      context "and the date range is same with the previous record date range" do
        it "passes the validation" do
          subject.valid?
          expect(subject.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies between the previous record date range" do
        it "passes the validation" do
          subject.start_date = Date.today - 30.days
          subject.end_date = Date.today - 15.days
          subject.valid?
          expect(subject.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies partially between the previous record date range" do
        it "passes the validation" do
          subject.start_date = Date.today - 60.days
          subject.end_date = Date.today - 30.days
          subject.valid?
          expect(subject.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range is different with the previous record date range " do
        it "passes the validation" do
          subject.start_date = Date.today - 100.days
          subject.end_date = Date.today - 70.days
          subject.valid?
          expect(subject.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end
    end

    context "when the interest_type is same with the previous record interest_type" do
      let(:overlapped_interest_rate) { create(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }
      
      before { overlapped_interest_rate }
      
      context "and the date range is same with the previous record date range" do
        it "fails the validation and the error is raised" do
          subject.valid?
          expect(subject.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies between the previous record date range" do
        it "fails the validation and the error is raised" do
          subject.start_date = Date.today - 30.days
          subject.end_date = Date.today - 15.days
          subject.valid?
          expect(subject.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies partially between the previous record date range" do
        it "fails the validation and the error is raised" do
          subject.start_date = Date.today - 60.days
          subject.end_date = Date.today - 30.days
          subject.valid?
          expect(subject.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range is different with the previous record date range " do
        it "passes the validation" do
          subject.start_date = Date.today - 100.days
          subject.end_date = Date.today - 80.days
          subject.valid?
          expect(subject.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end
    end
  end
end
