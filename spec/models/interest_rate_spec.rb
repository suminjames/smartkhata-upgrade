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
        expect(invalid_interest_rate.errors[:start_date]).to eq(["Start date should be before the end date"])
      end
    end

    context "when start_date is less than end_date" do
      let(:start_date) { Date.today - 7.days }
      let(:end_date) { Date.today - 4.days }
      let(:valid_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date) }

      it "passes the validation" do
        valid_interest_rate.valid?
        expect(valid_interest_rate.errors[:start_date]).to_not eq(["Start date should be before the end date"])
      end
    end
  end

  describe "validate_interest_rate_overlap" do
    context "when the interest_type is different with previous record interest_type" do
      let(:interest_type) { "receivable" }

      context "and the date range is same with the previous record date range" do
        let(:start_date) { Date.today - 40.days }
        let(:end_date) { Date.today - 10.days }
        let(:valid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "passes the validation" do
          valid_overlapped_interest_rate.valid?
          expect(valid_overlapped_interest_rate.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies between the previous record date range" do
        let(:start_date) { Date.today - 30.days }
        let(:end_date) { Date.today - 20.days }
        let(:valid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "passes the validation" do
          valid_overlapped_interest_rate.valid?
          expect(valid_overlapped_interest_rate.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies partially between the previous record date range" do
        let(:start_date) { Date.today - 50.days }
        let(:end_date) { Date.today - 30.days }
        let(:valid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "passes the validation" do
          valid_overlapped_interest_rate.valid?
          expect(valid_overlapped_interest_rate.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range is different with the previous record date range " do
        let(:start_date) { Date.today - 100.days }
        let(:end_date) { Date.today - 70.days }
        let(:valid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "passes the validation" do
          valid_overlapped_interest_rate.valid?
          expect(valid_overlapped_interest_rate.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end
    end

    context "when the interest_type is same with the previous record interest_type" do
      let(:interest_type) { "payable" }

      context "and the date range is same with the previous record date range" do
        let(:start_date) { Date.today - 40.days }
        let(:end_date) { Date.today - 10.days }
        let(:invalid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "fails the validation and the error is raised" do
          expect(subject.start_date..subject.end_date).to eq(invalid_overlapped_interest_rate.start_date..invalid_overlapped_interest_rate.end_date)
          expect(subject.interest_type).to eq(invalid_overlapped_interest_rate.interest_type)

          invalid_overlapped_interest_rate.valid?
          expect(invalid_overlapped_interest_rate.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies between the previous record date range" do
        let(:start_date) { Date.today - 35.days }
        let(:end_date) { Date.today - 15.days }
        let(:invalid_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        it "fails the validation and the error is raised" do
          expect(subject.start_date..subject.end_date).to include(invalid_overlapped_interest_rate.start_date, invalid_overlapped_interest_rate.end_date)
          expect(subject.interest_type).to eq(invalid_overlapped_interest_rate.interest_type)
          invalid_overlapped_interest_rate.valid?
          expect(invalid_overlapped_interest_rate.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range lies partially between the previous record date range" do
        let(:start_date) { Date.today - 60.days }
        let(:end_date) { Date.today - 30.days }
        let(:partial_overlapped_interest_rate) { build(:interest_rate, start_date: start_date, end_date: end_date, interest_type: interest_type) }

        let(:another_start_date) { Date.today - 20.days}
        let(:another_end_date) { Date.today + 20.days }
        let(:another_partial_overlapped_interest_rate) { build(:interest_rate, start_date: another_start_date, end_date: another_end_date, interest_type: interest_type) }

        it "fails the validation and the error is raised" do
          expect(subject.start_date..subject.end_date).to include(partial_overlapped_interest_rate.end_date)
          expect(subject.start_date..subject.end_date).to include(another_partial_overlapped_interest_rate.start_date)

          expect(subject.interest_type).to eq(partial_overlapped_interest_rate.interest_type)
          expect(subject.interest_type).to eq(another_partial_overlapped_interest_rate.interest_type)

          partial_overlapped_interest_rate.valid?
          another_partial_overlapped_interest_rate.valid?

          expect(partial_overlapped_interest_rate.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
          expect(another_partial_overlapped_interest_rate.errors[:start_date]).to eq(["An interest rate record in the given date range already exists!"])
        end
      end

      context "and the date range is different with the previous record date range " do
        let(:start_date) { Date.today - 120.days }
        let(:end_date) { Date.today - 100.days }
        let(:another_interest_record) { build(:interest_rate, start_date: start_date, end_date: end_date) }

        it "passes the validation" do
          another_interest_record.valid?
          expect(another_interest_record.errors[:start_date]).to_not eq(["An interest rate record in the given date range already exists!"])
        end
      end
    end
  end
end
