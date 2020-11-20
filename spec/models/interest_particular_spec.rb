# == Schema Information
#
# Table name: interest_particulars
#
#  id            :integer          not null, primary key
#  amount        :float
#  rate          :integer
#  date          :date
#  interest_type :integer
#  ledger_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe InterestParticular, type: :model do

  let(:user) { create(:user) }
  let(:client_account) { create(:client_account, user: user) }
  let(:ledger) { create(:ledger, client_account: client_account) }
  let(:particular) { create(:particular, fy_code: 7778, transaction_type: 0, amount: 500, value_date: Date.today - 15.days) }
  let!(:interest_rate) { create(:interest_rate) }
  let(:date) { Date.today }

  describe "associations" do
    it { should belong_to(:ledger) }
  end

  it { should define_enum_for(:interest_type).with([:dr, :cr]) }

  describe ".calculate_interest" do
    let(:subject) { InterestParticular.calculate_interest(date) }
    let(:particular_net_calculator) { instance_double(ParticularNetCalculator) }

    context "when client ledger has particular" do
      before do
        ledger.particulars << particular
      end

      it "creates the record for interest particular" do
        expect(subject.num_inserts).to eq(1)
        expect(subject.ids).to include("1")
      end
    end

    context "when the client ledger has not particular" do
      it "doesn't create the record for interest particular" do
        expect(subject.num_inserts).to eq(0)
      end
    end

    context "when the total particular amount is negative" do
      let(:another_particular) { create(:particular, fy_code: 7778, transaction_type: 1, amount: 2000, value_date: Date.today - 10.days) }

      before do
        ledger.particulars << [particular, another_particular]
      end

      it "calculates payable interest" do
        expect(subject.num_inserts).to eq(1)
        relevant_interest_particular = InterestParticular.last
        expect(relevant_interest_particular.amount).to eq(150.0)
        expect(relevant_interest_particular.interest_type).to eq('dr')
      end
    end

    context "when the total particular amount is positive" do
      let(:another_particular) { create(:particular, fy_code: 7778, transaction_type: 1, amount: 500, value_date: Date.today - 10.days) }
      let(:third_particular){ create(:particular, fy_code: 7778, transaction_type: 0, amount: 1000, value_date: Date.today - 10.days) }

      before do
        ledger.particulars << [particular, another_particular, third_particular]
      end

      it "calculates receivable interest" do
        expect(subject.num_inserts).to eq(1)
        relevant_interest_particular = InterestParticular.last
        expect(relevant_interest_particular.amount).to eq(100.0)
        expect(relevant_interest_particular.interest_type).to eq('cr')
      end
    end
  end
end
